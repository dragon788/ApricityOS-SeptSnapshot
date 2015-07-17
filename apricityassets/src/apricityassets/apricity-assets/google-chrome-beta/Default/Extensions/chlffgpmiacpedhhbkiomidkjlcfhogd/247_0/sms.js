'use strict';

pb.addEventListener('signed_in', function(e) {
    pb.addEventListener('connected', function(e) {
        pb.smsQueue = [];
        pb.threads = {};

        Object.keys(pb.notifier.active).forEach(function(key) {
            if (key.indexOf('sms') != -1) {
                pb.notifier.dismiss(key);
            }
        });

        pb.dispatchEvent('sms_changed');
    });

    pb.addEventListener('stream_message', function(e) {
        var message = e.detail;
        if (message.type != 'push' || !message.push) {
            return;
        }

        var push = message.push;
        if (push.type != 'sms_changed') {
            return;
        }

        pb.log('SMS changed');

        pb.dispatchEvent('sms_changed');
    });

    pb.addEventListener('locals_changed', function(e) {
        getSmsDevices().forEach(function(device) {
            if (!pb.threads[device.iden]) {
                pb.get(pb.api + '/v2/permanents/' + device.iden + '_threads', function(response) {
                    if (response) {
                        pb.threads[device.iden] = mapify(response);
                    }
                });
            }
        });
    });

    pb.addEventListener('sms_changed', function(e) {
        getSmsDevices().forEach(function(device) {
            pb.get(pb.api + '/v2/permanents/' + device.iden + '_threads', function(response) {
                if (response) {
                    var currentThreads = mapify(response);
                    var previousThreads = pb.threads[device.iden];

                    pb.threads[device.iden] = currentThreads;

                    if (!previousThreads) {
                        return;
                    }

                    var keySet = {};
                    Object.keys(currentThreads).concat(Object.keys(previousThreads)).forEach(function(key) {
                        keySet[key] = true;
                    });

                    Object.keys(keySet).forEach(function(key) {
                        var current = currentThreads[key];
                        var previous = previousThreads[key];

                        if (!current || !current.latest || current.latest.direction != 'incoming') {
                            return;
                        }

                        if (previous && previous.latest) {
                            if (previous.latest.id == current.latest.id) {
                                return;
                            }
                        }

                        notifyForSms(device, current);
                    });
                }
            });
        });
    });
});

var mapify = function(response) {
    var map = {};
    response.threads.forEach(function(thread) {
        map[thread.id] = thread;
    });
    return map;
}

var notifyForSms = function(device, thread) {
    var chatInfo = pb.findChat(device.iden + '_thread_' + thread.id);
    if (chatInfo && chatInfo.focused) {
        return;
    }

    var name, imageUrl;
    if (thread.recipients.length == 1) {
        var recipient = thread.recipients[0];
        name = recipient.name;
        imageUrl = recipient.thumbnail ? 'data:image/jpeg;base64,' + recipient.thumbnail : 'chip_person.png';
    } else {
        name = thread.recipients.map(function(recipient) { return recipient.name; }).join(', ');
        imageUrl = 'chip_group.png';
    }

    var options = {};
    options.type = 'basic';
    options.key = 'sms' + '_' + device.iden + '_thread_' + thread.id;
    options.iconUrl = imageUrl;
    options.title = name
    options.message = thread.latest.body;
    options.buttons = [];

    options.contextMessage = String.format(text.get('push_context_message'),
                    name,
                    new Date(Math.floor(thread.latest.timestamp * 1000)).toLocaleTimeString().replace(/:\d+ /, ' '));

    options.onclick = function() {
        openSmsWindow(device, thread);
        sendSmsDismissal();
    };

    if (thread.recipients.length == 1) {
        options.buttons.push({
            'title': text.get('reply'),
            'iconUrl': 'action_sms.png',
            'onclick': function() {
                openSmsWindow(device, thread);
                sendSmsDismissal();
            }
        });
    }

    options.buttons.push({
        'title': text.get('dismiss'),
        'iconUrl': 'action_cancel.png',
        'onclick': function() {
            sendSmsDismissal();
        }
    });


    utils.checkNativeClient(function(response) {
        if (!response) {
            pb.notifier.show(options);   
        }
    });
};

var openSmsWindow = function(device, thread) {
    pb.openChat('sms', device.iden + '_thread_' + thread.id);
};

var sendSmsDismissal = function() {
    var dismissal = {
        'type': 'dismissal',
        'package_name': 'sms',
        'notification_id': 0,
        'notification_tag': null,
        'source_user_iden': pb.local.user.iden
    };

    pb.post(pb.api + '/v2/ephemerals', {
        'type': 'push',
        'push': dismissal,
        'targets': ['stream', 'android']
    }, function(response) {
        if (response) {
            pb.log('Triggered remote sms dismissal');
        } else {
            pb.log('Failed to trigger remote sms dismissal');
        }
    });
};

var getSmsDevices = function() {
    return utils.asArray(pb.local.devices).filter(function(device) { return device.has_sms; });
};

pb.sendSms = function(deviceIden, threadId, address, body) {
    var sms = {
        'device_iden': deviceIden,
        'thread_id': threadId,
        'address': address,
        'body': body,
        'guid': utils.guid()
    };

    pb.smsQueue.push(sms);

    pb.dispatchEvent('locals_changed');

    processSmsQueue();

    return sms;
};

var processingSms = false;
var processSmsQueue = function() {
    if (processingSms) {
        return;
    }

    var sms = pb.smsQueue[0];
    if (!sms) {
        return;
    }

    processingSms = true;

    var real = {
        'type': 'messaging_extension_reply',
        'package_name': 'com.pushbullet.android',
        'source_user_iden': pb.local.user.iden,
        'target_device_iden': sms.device_iden,
        'conversation_iden': sms.address,
        'message': sms.body,
        'guid': sms.guid
    };

    pb.post(pb.api + '/v2/ephemerals', {
        'type': 'push',
        'push': real
    }, function(response) {
        pb.smsQueue.shift();

        processingSms = false;

        pb.dispatchEvent('locals_changed');

        processSmsQueue();
    });

    pb.dispatchEvent('active');
}
