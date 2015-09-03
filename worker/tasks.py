from celery import Celery
from celery.signals import celeryd_init
import subprocess
from time import sleep
import requests
import logging
import json
from billiard import current_process
from config import *
from netaddr import IPNetwork
import re
import socket
import shutil
import os
import traceback
from datetime import datetime
import dateutil.parser
import redis
from requests.exceptions import ConnectionError
from celery.exceptions import SoftTimeLimitExceeded


class NodeManager:

    def __init__(self, test_run, browser, platform):
        self.test_run = test_run
        self.vm_name = "cobs_thread%s_%s" % (current_process().index, test_run)
        self.vm_host = socket.gethostname()
        self.browser = browser.lower()
        self.platform = platform
        self.index = current_process().index + 1
        self.rdp_port = str(9001 + current_process().index)

    def __execute_cmd(self, cmd):
        self.__vm_log("info", "Executing cmd: %s" % " ".join(cmd))
        p = subprocess.Popen(
            cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        r = p.communicate()
        self.__vm_log("info", r[0])
        if len(r[1].strip().replace('0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%', '')) > 0:
            self.__vm_log("error", r[1])
        return r

    def __vm_log(self, level, log_entry):
        if level == "info":
            logging.warning(log_entry)
        if level == "error":
            logging.error(log_entry)
        if len(str(log_entry).strip()) > 0:
            self.__send_to_elk({
                'vm_name': self.vm_name,
                'vm_host': socket.gethostname(),
                'rdp_port': self.rdp_port,
                'applicationName': self.test_run,
                'log': self.test_run,
                'TEST_TYPE': 'VM_STATUS',
                'log_level': level,
                'log_entry': log_entry
            })

    def __get_etcd(self, key, value):
        logging.warning("getting etcd key=%s, value=%s" % (key, value))
        retries = 0
        while retries < 3:
            retries += 1
            try:
                r = requests.get(
                    'http://%s:4001/v2/keys/taste/%s/%s' % (METEOR_HOST_IP, key, value))
                return r
            except ConnectionError as e:
                self.__vm_log(
                    'warning', 'ConnectionError exception when trying to get status from etcd: %s' % e)
                sleep(2)
                continue

    def __update_etcd(self, key, value):
        logging.warning("updating etcd key=%s, value=%s" % (key, value))
        payload = {'value': value, 'ttl': 3600}
        r = requests.put('http://%s:4001/v2/keys/%s' %
                         (METEOR_HOST_IP, key), data=payload)
        try:
            r.raise_for_status()
        except Exception as e:
            self.__vm_log("error", e)
            self.remove_vm()
            self.get_video()
            raise Exception("Failed to update etcd")

    def __send_to_elk(self, item):
        """
        send `item` to Logstash port
        :param item: dict
        :return: None
        """
        try:
            r = redis.StrictRedis(host=HUBHOST, port=6379, db=0)
            r.rpush('logstash', json.dumps(item))
        except Exception as e:
            logging.error(e)
            logging.error('Failed to send logs to logstash')

    def __update_node_status(self, status):
        self.__vm_log("info", "updating node_status node_status=%s" % status)
        self.__update_etcd('taste/%s/status' % self.test_run, status)

        r = requests.put('%s/tests/%s/node-status/%s' %
                         (METEOR_HOST, self.test_run, status))
        try:
            r.raise_for_status()
        except Exception as e:
            error = 'Failed to update node status. Is the METEOR_HOST up?'
            self.__vm_log('error', e)
            self.remove_vm()
            self.get_video()
            raise Exception(error)

    def __update_remote_info(self):
        self.__vm_log("info", "updating remote_info host=%s, port=%s" % (
            self.vm_host, self.rdp_port))
        r = requests.put('%s/tests/%s/remote-info/%s/%s' %
                         (METEOR_HOST, self.test_run, self.vm_host, self.rdp_port))
        try:
            r.raise_for_status()
        except Exception as e:
            error = 'Failed to update remote info. Is the METEOR_HOST up?'
            self.__vm_log('error', e)
            self.remove_vm()
            self.get_video()
            raise Exception(error)

    def __update_has_video(self, has_video):
        self.__vm_log("info", "updating has_video=%s" % (has_video))
        r = requests.put('%s/tests/%s/has-video/%s' %
                         (METEOR_HOST, self.test_run, has_video))
        try:
            r.raise_for_status()
        except Exception as e:
            error = 'Failed to update has_video. Is the METEOR_HOST up?'
            self.__vm_log('error', e)
            self.remove_vm()
            self.get_video()
            raise Exception(error)

    def wait_for_test(self):
        retries = 0
        max_retries = TIMEOUT_TEST_BEGIN / 2
        self.__vm_log(
            'info', 'Waiting for test to begin (timeout after %s seconds)...' % TIMEOUT_TEST_BEGIN)
        while retries < max_retries:
            retries += 1
            r = self.__get_etcd(self.test_run, 'status')
            status = r.json()['node']['value']
            self.__vm_log("info", "status: %s" % status)  # debug
            if status == "in_progress":
                self.__vm_log("info", "Test in progress...")
                break
            sleep(2)

        if retries == max_retries:
            error = 'Timed out waiting for test to begin.'
            self.__vm_log('error', error)
            self.remove_vm()
            self.get_video()
            raise Exception(error)

        retries = 0
        max_retries = TIMEOUT_TEST_COMPLETE / 2
        self.__vm_log(
            'info', 'Waiting for test to finish (timeout after %s seconds)...' % TIMEOUT_TEST_COMPLETE)
        while retries < max_retries:
            retries += 1
            r = self.__get_etcd(self.test_run, 'status')
            status = r.json()['node']['value']
            self.__vm_log("info", "status: %s" % status)  # debug
            if status == "finished" or status == "break_point":
                self.__vm_log("info", "Test complete")
                self.__update_node_status(status)
                return

            # only check last command after a few tries
            if retries >= 30:
                r = self.__get_etcd(self.test_run, 'last_command')
                last_command = r.json()['node']['value']
                last_command_date = dateutil.parser.parse(last_command)
                seconds_since_last_command = (
                    datetime.utcnow() - last_command_date).total_seconds()
                self.__vm_log(
                    "info", "Seconds since last command: %s" % seconds_since_last_command)
                if seconds_since_last_command > TIMEOUT_TEST_IDLE:
                    self.__vm_log(
                        "error", "Seconds since last command has exceeded the TIMEOUT_IDLE limit!")
                    break
            sleep(2)

        # if it makes it this far, it failed to finish
        self.__vm_log(
            "error", "Test did not complete successfully (test status never updated to 'finish')")
        self.__update_node_status(status)

    def check_for_failed_vm(self):
        r = self.__execute_cmd([
            'VBoxManage',
            'list',
            'vms'
        ])
        x = re.findall(
            'cobs_thread%s_[0-9a-zA-Z]*' % current_process().index, r[0])
        if len(x) > 0:
            self.__vm_log(
                "warning", "A failed VM was found before starting test. Cleaning up...")
            self.remove_vm(x[0])

    def create_vm(self):
        try:
            base_image = VALID_COMBOS[self.browser][self.platform]
        except Exception as e:
            self.__update_node_status('failed')
            error = 'Invalid browser/platform combination.'
            self.__vm_log('error', e)
            raise Exception(error)

        self.__vm_log("info", "Using base image: %s" % base_image)
        r = self.__execute_cmd([
            'VBoxManage',
            'clonevm', base_image,
            '--options', 'link',
            '--name', '%s' % self.vm_name,
            '--snapshot', 'Selenium',
            '--register'
        ])
        if len(r[1].strip().replace('0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%', '')) > 0:
            error = 'Failed to create VM!'
            self.remove_vm()
            raise Exception("Failed to create VM!")

    def set_application_name(self):
        r = self.__execute_cmd([
            'VBoxManage',
            'guestproperty',
            'set',
            '%s' % self.vm_name,
            'APPLICATION_NAME',
            '%s' % self.test_run
        ])

    def start_vm(self):
        r = self.__execute_cmd([
            'VBoxManage',
            'startvm',
            '%s' % self.vm_name,
            '-type', 'headless'
        ])
        if len(r[1].strip()) > 0:
            error = 'Failed to start VM!'
            self.__vm_log('error', error)
            self.remove_vm()
            self.get_video()
            raise Exception(error)
        self.__vm_log("info", "waiting for vm...")
        self.__update_node_status('waiting')

    def wait_for_vm(self):
        retries = 0
        max_retries = TIMEOUT_WAIT_FOR_VM / 2

        while retries < max_retries:
            retries += 1
            r = self.__get_etcd(self.test_run, 'status')
            print r.text
            status = r.json()['node']['value']
            self.__vm_log('info', 'status: %s' % status)
            if status == "in_progress":
                return
            sleep(2)
        self.__update_node_status('failed')
        error = 'Timeout exceeded 120 seconds waiting for VM to boot'
        self.__vm_log('error', error)
        self.remove_vm()
        self.get_video()
        raise Exception(error)

    def enable_video_capture(self):
        self.__vm_log("info", "Enabling video capture on VM")
        r = self.__execute_cmd([
            'VBoxManage',
            'modifyvm',
            '%s' % self.vm_name,
            '--vcpenabled', 'on',
            '--vcpwidth', '1280',
            '--vcpheight', '1024'
        ])

    def configure_vrdeport(self):
        self.__vm_log("info", "Configuring remote display port on VM")
        self.__update_remote_info()
        r = self.__execute_cmd([
            'VBoxManage',
            'modifyvm', '%s' % self.vm_name,
            '--vrdeport', self.rdp_port
        ])

    def configure_static_ip(self, custom_dns=False):
        self.__vm_log("info", "Configuring network on VM")
        network = IPNetwork(STATIC_NETWORK)
        avail = []
        for ip in network[2:-1]:
            avail.append(str(ip))

        dns = STATIC_DNS
        if custom_dns:
            dns = custom_dns
            self.__vm_log('warning', 'Using custom DNS %s' % dns)

        ip = avail[current_process().index]
        netmask = str(network.netmask)

        r = self.__execute_cmd([
            'VBoxManage',
            'hostonlyif',
            'ipconfig',
            'vboxnet0',
            '--ip', str(network[1])
        ])
        r = self.__execute_cmd([
            'VBoxManage',
            'guestproperty',
            'set', '%s' % self.vm_name,
            'STATIC_IP', '%s' % ip
        ])
        r = self.__execute_cmd([
            'VBoxManage',
            'guestproperty',
            'set', '%s' % self.vm_name,
            'STATIC_GATEWAY', str(network[1])
        ])
        r = self.__execute_cmd([
            'VBoxManage',
            'guestproperty',
            'set', '%s' % self.vm_name,
            'STATIC_DNS', dns
        ])
        r = self.__execute_cmd([
            'VBoxManage',
            'guestproperty',
            'set', '%s' % self.vm_name,
            'STATIC_NETMASK', str(network.netmask)
        ])

    def configure_hubhost(self):
        self.__vm_log("info", "Configuring hubhost on VM")
        r = self.__execute_cmd([
            'VBoxManage',
            'guestproperty',
            'set',
            '%s' % self.vm_name,
            'HUBHOST', '%s' % HUBHOST
        ])

    def remove_vm(self, vm_name=None, tries=0):
        update_node_status = False

        # should we break?
        r = self.__get_etcd(self.test_run, 'status')
        status = r.json()['node']['value']
        if status == "break_point":
            update_node_status = True
            waiting = 0
            while waiting < TIMEOUT_BREAK_ON_FAILURE / 5:
                waiting += 1
                self.__vm_log('info', 'break_point = true.')
                r = self.__get_etcd(self.test_run, 'status')
                status = r.json()['node']['value']
                # check status. if finished, break out of loop and terminate VM
                if status == "finished":
                    break
                sleep(5)
            self.__vm_log("info", "Break point complete, terminating session.")
        if vm_name is None:
            update_node_status = True
            vm_name = self.vm_name
        r = self.__execute_cmd([
            'VBoxManage',
            'controlvm',
            '%s' % vm_name,
            'poweroff'
        ])

        r = self.__execute_cmd([
            'VBoxManage',
            'unregistervm',
            '%s' % vm_name,
            '--delete'
        ])
        if update_node_status:
            self.__update_node_status('terminated')

    def kill_vm_process(self, vm_name=None):
        if vm_name is None:
            vm_name = self.vm_name
        p = subprocess.Popen(
            "kill $(ps aux | grep -v grep | grep %s | awk '{print $2}')" % self.vm_name,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT)
        r = p.communicate()
        self.__vm_log(
            'info', 'Attempting to kill VM process manually...')
        self.__vm_log(
            'info', 'Result of kill cmd %s' % str(r))

    def get_video(self):
        self.__vm_log(
            'info', 'Retrieving video of test session %s' % self.vm_name)
        try:
            shutil.move(
                '%s/%s/%s.webm' % (VBOX_MACHINE_DIR,
                                   self.vm_name, self.vm_name),
                '%s/%s.webm' % (SCREENCAST_DEST_DIR, self.test_run)
            )
            os.chmod('%s/%s.webm' % (SCREENCAST_DEST_DIR, self.test_run), 0644)
            self.__update_has_video(1)
        except Exception as e:
            self.__vm_log('error', e)
            self.__vm_log(
                'error', 'Error occurred while trying to retrieve video.')

    def cleanup_vm_dir(self):
        try:
            shutil.rmtree('%s/%s' % (VBOX_MACHINE_DIR, self.vm_name))
        except Exception as e:
            self.__vm_log('error', e)
            self.__vm_log(
                'error',
                'Error occurred while trying to remove VM directory %s/%s' % (VBOX_MACHINE_DIR, self.vm_name))

app = Celery('taste', broker=RABBITMQ_SERVER)
app.conf.CELERY_ACCEPT_CONTENT = ['json', 'msgpack', 'yaml']
app.conf.CELERYD_TASK_SOFT_TIME_LIMIT = 3600
app.conf.CELERY_ACKS_LATE = True
app.conf.CELERYD_PREFETCH_MULTIPLIER = 1
app.conf.CELERYD_CONCURRENCY = 24

@celeryd_init.connect
def configure_workers(sender=None, conf=None, **kwargs):
    cmd = ['VBoxManage', 'list', 'hostonlyifs']
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    resp = p.communicate()
    x = re.findall('^Name:\s*vboxnet0\n', resp[0])
    print(x)
    if len(x) == 0:
        logging.warning("Need to create hostonly")
        cmd = ['VBoxManage', 'hostonlyif', 'create']
        p = subprocess.Popen(
            cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        resp = p.communicate()[0]
        logging.warning(resp)


@app.task()
def start_node(test_run, browser, platform, custom_dns=False):
    try:
        mgr = NodeManager(test_run, browser, platform)
        mgr.check_for_failed_vm()
        mgr.create_vm()
        mgr.enable_video_capture()
        mgr.configure_vrdeport()
        mgr.set_application_name()
        mgr.configure_static_ip(custom_dns)
        mgr.configure_hubhost()
        mgr.start_vm()
        mgr.wait_for_vm()
        mgr.wait_for_test()
        mgr.remove_vm()
        mgr.get_video()
        mgr.cleanup_vm_dir()
    except SoftTimeLimitExceeded:
        mgr.kill_vm_process()
        mgr.remove_vm()
        mgr.cleanup_vm_dir()
