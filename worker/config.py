import os

# CIDR format. Example: 192.168.59.0/24.
# This should match network for vboxnet0
if "STATIC_NETWORK" in os.environ.keys():
    STATIC_NETWORK = os.environ['STATIC_NETWORK']
else:
    print("ERROR!!! STATIC_NETWORK variable not set. Aborting!!!")
    exit(1)

# configure these (defaults provided)
RABBITMQ_SERVER = "amqp://guest@192.168.59.103//"
if "RABBITMQ_SERVER" in os.environ.keys():
    RABBITMQ_SERVER = os.environ['RABBITMQ_SERVER']

HUBHOST = "192.168.59.103"
if "HUBHOST" in os.environ.keys():
    HUBHOST = os.environ['HUBHOST']

TIMEOUT_WAIT_FOR_VM = 180
if "TIMEOUT_WAIT_FOR_VM" in os.environ.keys():
    TIMEOUT_WAIT_FOR_VM = os.environ['TIMEOUT_WAIT_FOR_VM']

TIMEOUT_TEST_BEGIN = 120
if "TIMEOUT_TEST_BEGIN" in os.environ.keys():
    TIMEOUT_TEST_BEGIN = os.environ['TIMEOUT_TEST_BEGIN']

TIMEOUT_TEST_IDLE = 180
if "TIMEOUT_TEST_IDLE" in os.environ.keys():
    TIMEOUT_TEST_IDLE = os.environ['TIMEOUT_TEST_IDLE']

TIMEOUT_TEST_COMPLETE = 600
if "TIMEOUT_TEST_COMPLETE" in os.environ.keys():
    TIMEOUT_TEST_COMPLETE = os.environ['TIMEOUT_TEST_COMPLETE']

TIMEOUT_BREAK_ON_FAILURE = 900
if "TIMEOUT_BREAK_ON_FAILURE" in os.environ.keys():
    TIMEOUT_BREAK_ON_FAILURE = os.environ['TIMEOUT_BREAK_ON_FAILURE']

STATIC_DNS = "8.8.8.8"
if "STATIC_DNS" in os.environ.keys():
    STATIC_DNS = os.environ['STATIC_DNS']

METEOR_HOST_IP = "192.168.59.103"
if "METEOR_HOST_IP" in os.environ.keys():
    METEOR_HOST_IP = os.environ['METEOR_HOST_IP']

METEOR_HOST_PORT = "3000"
if "METEOR_HOST_PORT" in os.environ.keys():
    METEOR_HOST_PORT = os.environ['METEOR_HOST_PORT']

METEOR_HOST = "http://%s:%s" % (METEOR_HOST_IP, METEOR_HOST_PORT)

VBOX_USER_HOME = "~/VirtualBox VMs"
if "VBOX_USER_HOME" in os.environ.keys():
    VBOX_USER_HOME = os.environ['VBOX_USER_HOME']

# Use same directory as VBOX_USER_HOME, but allow override if necessary
VBOX_MACHINE_DIR = VBOX_USER_HOME
if "VBOX_MACHINE_DIR" in os.environ.keys():
    VBOX_MACHINE_DIR = os.environ['VBOX_MACHINE_DIR']

if "SCREENCAST_DEST_DIR" in os.environ.keys():
    SCREENCAST_DEST_DIR = os.environ['SCREENCAST_DEST_DIR']

# VALID_COMBOS['browser']['platform'] = IMAGE
VALID_COMBOS = {
    'ie9': {
        'Windows 7': 'base_IE9Win7'
    },
    'ie10': {
        'Windows 7': 'base_IE10Win7'
    },
    'ie11': {
        'Windows 7': 'base_IE11Win7'
    },
    'chrome': {
        'Windows 7': 'IE11 - Win7'
    },
    'firefox': {
        'Windows 7': 'IE11 - Win7'
    }
}
