import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  // Injected by Omarchy's service loader.
  property var shell: null
  property bool syncQueued: false

  function applyTransparency(value) {
    var bar = shell ? shell.bar : null
    if (!bar || !("transparent" in bar)) {
      barRetry.restart()
      return false
    }

    // Change only the live bar surface. Keeping the theme text color avoids
    // the delayed wallpaper-contrast probe used by the built-in toggle.
    bar.useTransparentForeground = false
    bar.transparent = value
    return true
  }

  function syncWorkspace() {
    if (workspaceProbe.running) {
      syncQueued = true
      return
    }
    workspaceProbe.running = true
  }

  function handleEvent(event) {
    var name = String(event || "").split(">>")[0]
    switch (name) {
      case "workspace":
      case "workspacev2":
      case "focusedmon":
      case "focusedmonv2":
      case "activespecial":
      case "activespecialv2":
      case "openwindow":
      case "closewindow":
      case "movewindow":
      case "movewindowv2":
      case "activewindow":
      case "activewindowv2":
      case "createworkspace":
      case "createworkspacev2":
      case "destroyworkspace":
      case "destroyworkspacev2":
        syncWorkspace()
        break
    }
  }

  Process {
    id: workspaceProbe
    command: ["hyprctl", "activeworkspace", "-j"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var workspace = JSON.parse(text)
          root.applyTransparency(Number(workspace.windows || 0) === 0)
        } catch (e) {
          root.applyTransparency(false)
        }
      }
    }
    onExited: {
      if (root.syncQueued) {
        root.syncQueued = false
        root.syncWorkspace()
      }
    }
  }

  Process {
    id: eventStream
    command: ["bash", "-c", "exec socat -u \"UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock\" -"]
    stdout: SplitParser {
      onRead: function(line) { root.handleEvent(line) }
    }
    onExited: eventReconnect.restart()
  }

  Timer {
    id: eventReconnect
    interval: 150
    repeat: false
    onTriggered: if (!eventStream.running) eventStream.running = true
  }

  Timer {
    id: barRetry
    interval: 100
    repeat: false
    onTriggered: root.syncWorkspace()
  }

  Component.onCompleted: {
    syncWorkspace()
    eventStream.running = true
  }

  // Disabling or removing the plugin always restores the normal opaque bar.
  Component.onDestruction: applyTransparency(false)
}
