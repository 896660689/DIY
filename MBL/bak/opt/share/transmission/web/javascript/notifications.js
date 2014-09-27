var Notifications = {};

$(document).ready(function () {
  if (!window.webkitNotifications) {
    return;
  }

  var notificationsEnabled = (window.webkitNotifications.checkPermission() === 0),
      toggle = $('#toggle_notifications');

  toggle.show();
  updateMenuTitle();
  $(transmission).bind('downloadComplete seedingComplete', function (event, torrent) {
    var title = (event.type == 'downloadComplete' ? '下载' : '做种') + '完成',
        content = torrent.getName(),
        notification;

    notification = window.webkitNotifications.createNotification('style/transmission/images/logo.png', title, content);
    notification.show();
    setTimeout(function () {
      notification.cancel();
    }, 5000);
  });

  function updateMenuTitle() {
    toggle.html('桌面通告' + (notificationsEnabled ? '已禁用' : '已启用'));
  }

  Notifications.toggle = function () {
    if (window.webkitNotifications.checkPermission() !== 0) {
      window.webkitNotifications.requestPermission(function () {
        notificationsEnabled = (window.webkitNotifications.checkPermission() === 0);
        updateMenuTitle();
      });
    } else {
      notificationsEnabled = !notificationsEnabled;
      updateMenuTitle();
    }
  };
});