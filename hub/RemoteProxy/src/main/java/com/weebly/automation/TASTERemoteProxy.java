package com.weebly.automation;

import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.sql.Timestamp;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.logging.Logger;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.simple.JSONValue;
import org.openqa.grid.common.RegistrationRequest;
import org.openqa.grid.internal.Registry;
import org.openqa.grid.internal.TestSession;
import org.openqa.grid.internal.listeners.TestSessionListener;
import org.openqa.grid.selenium.proxy.DefaultRemoteProxy;

import redis.clients.jedis.Jedis;

public class TASTERemoteProxy extends DefaultRemoteProxy implements TestSessionListener {

	private static final Logger log = Logger.getLogger(DefaultRemoteProxy.class.getName());
	private String applicationName;

	public TASTERemoteProxy(RegistrationRequest request, Registry registry) {
		super(request, registry);
		applicationName = request.getCapabilities().get(0).asMap().get("applicationName").toString();
	}

	private void updateEtcd(String key, String value) throws Exception {
		int count = 0;
		while (count < 3) {
			count += 1;
			String ETCD_HOST = System.getenv("ETCD_HOST");
			if (ETCD_HOST == null) {
				log.warning("ETCD_HOST NOT CONFIGURED CORRECTLY. NOT UPDATING ETCD.");
				return;
			}
			URL url = new URL(ETCD_HOST + "/v2/keys/" + key + "/?value=" + value);
			HttpURLConnection connection = (HttpURLConnection) url.openConnection();
			connection.setRequestMethod("PUT");
			connection.setDoOutput(true);
			connection.setConnectTimeout(30000);
			OutputStreamWriter osw = new OutputStreamWriter(connection.getOutputStream());
			osw.flush();
			osw.close();
			if (connection.getResponseCode() == HttpURLConnection.HTTP_OK)
				break;
			log.warning("HTTPUrlConnnection failed, retrying (updateEtcd)..");
			Thread.sleep(3000);
		}
	}

	private void sendToLogstash(Map<String, String> item) throws Exception {
		String REDIS_HOST = System.getenv("REDIS_HOST");
		if (REDIS_HOST == null) {
			log.warning("REDIS_HOST NOT CONFIGURED CORRECTLY. NOT UPDATING REDIS/LOGSTASH.");
			return;
		}
		item.put("log_type", "node_log");
		String jsonText = JSONValue.toJSONString(item);
		Jedis jedis = new Jedis(REDIS_HOST);
		jedis.rpush("logstash", jsonText);
		jedis.close();
	}

	private void updateNodeManager(String key, String value) throws Exception {
		int count = 0;
		while (count < 3) {
			count += 1;
			String METEOR_HOST = System.getenv("METEOR_HOST");
			if (METEOR_HOST == null) {
				log.warning("METEOR_HOST NOT CONFIGURED CORRECTLY. NOT UPDATING NODE MANAGER.");
				return;
			}
			URL url = new URL(METEOR_HOST + "/tests/" + key + "/" + value);
			HttpURLConnection connection = (HttpURLConnection) url.openConnection();
			connection.setRequestMethod("PUT");
			connection.setDoOutput(true);
			connection.setConnectTimeout(30000);
			OutputStreamWriter osw = new OutputStreamWriter(connection.getOutputStream());
			osw.flush();
			osw.close();
			if (connection.getResponseCode() == HttpURLConnection.HTTP_OK)
				break;
			log.warning("HTTPUrlConnnection failed, retrying (updateNodeManager)..");
			Thread.sleep(3000);
		}
	}

	@Override
	public void beforeSession(TestSession session) {
		super.beforeSession(session);
		try {
			updateEtcd("taste/" + applicationName + "/status", "in_progress");
			updateNodeManager(applicationName + "/node-status", "in_progress");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public void afterSession(TestSession session) {
		super.afterSession(session);
		teardown();
		Registry registry = this.getRegistry();
		registry.removeIfPresent(this);

		try {
			updateNodeManager(applicationName + "/node-status", "finished");
			updateEtcd("taste/" + applicationName + "/status", "finished");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void beforeCommand(TestSession session, HttpServletRequest request, HttpServletResponse response) {
		super.beforeCommand(session, request, response);
		Map<String, String> item = new LinkedHashMap<String, String>();
		item.put("applicationName", applicationName);
		item.put("message", "beforeCommand");
		item.put("log_level", "info");
		item.put("request", request.toString());
		item.put("response", response.toString());

		try {
			sendToLogstash(item);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public void afterCommand(TestSession session, HttpServletRequest request, HttpServletResponse response) {
		super.afterCommand(session, request, response);
		try {
			updateEtcd("taste/" + applicationName + "/last_command",
					URLEncoder.encode(new Timestamp(new Date().getTime()).toString(), "UTF-8"));
		} catch (Exception e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
	}

}
