# Initial settings only; GUI changes are preserved after activation.
{ configHome }:
{
  "currentThemeName" = "custom";
  "currentThemeCategory" = "registry";
  "registryThemeVariants" = {
    "catppuccin" = {
      "dark" = {
        "flavor" = "mocha";
        "accent" = "mauve";
      };
    };
  };
  "popupTransparency" = 0.7;
  "widgetColorMode" = "colorful";
  "cornerRadius" = 12;
  "mouseAccelProfile" = "flat";
  "touchpadDisableOnExternalMouse" = true;
  "m3ElevationIntensity" = 50;
  "m3ElevationOpacity" = 50;
  "blurEnabled" = true;
  "foregroundLayerTransparency" = 0.7;
  "blurLayerOutlineOpacity" = 0;
  "controlCenterShowMicPercent" = true;
  "showOccupiedWorkspacesOnly" = true;
  "appIdSubstitutions" = [
  ];
  "spotlightSectionViewModes" = {
    "apps" = "grid";
  };
  "cursorSettings" = {
    "theme" = "Adwaita";
    "size" = 30;
    "niri" = {
      "hideWhenTyping" = false;
      "hideAfterInactiveMs" = 0;
    };
    "hyprland" = {
      "hideOnKeyPress" = false;
      "hideOnTouch" = false;
      "inactiveTimeout" = 0;
    };
    "mango" = {
      "cursorHideTimeout" = 0;
    };
  };
  "fontFamily" = "JetBrains Mono";
  "monoFontFamily" = "JetBrains Mono";
  "osdPowerProfileEnabled" = true;
  "barConfigs" = [
    {
      "id" = "default";
      "name" = "Main Bar";
      "enabled" = true;
      "position" = 0;
      "screenPreferences" = [
        "all"
      ];
      "showOnLastDisplay" = true;
      "leftWidgets" = [
        {
          "id" = "workspaceSwitcher";
          "enabled" = true;
        }
        {
          "id" = "focusedWindow";
          "enabled" = true;
        }
      ];
      "centerWidgets" = [
        "music"
        "clock"
        "weather"
      ];
      "rightWidgets" = [
        "systemTray"
        {
          "id" = "clipboard";
          "enabled" = true;
        }
        {
          "id" = "cpuUsage";
          "enabled" = false;
        }
        {
          "id" = "memUsage";
          "enabled" = false;
        }
        {
          "id" = "notificationButton";
          "enabled" = true;
        }
        {
          "id" = "battery";
          "enabled" = false;
        }
        {
          "id" = "controlCenterButton";
          "enabled" = true;
          "showBluetoothIcon" = false;
        }
      ];
      "spacing" = 4;
      "innerPadding" = 5;
      "barInsetPadding" = 10;
      "barLengthPadding" = 0;
      "bottomGap" = 0;
      "attachToScreenEdge" = false;
      "transparency" = 1;
      "widgetTransparency" = 0.5;
      "squareCorners" = false;
      "noBackground" = false;
      "maximizeWidgetIcons" = false;
      "maximizeWidgetText" = false;
      "removeWidgetPadding" = false;
      "widgetPadding" = 5;
      "batteryColorMode" = "theme";
      "gothCornersEnabled" = false;
      "gothCornerRadiusOverride" = false;
      "gothCornerRadiusValue" = 12;
      "borderEnabled" = false;
      "borderColor" = "surfaceText";
      "borderOpacity" = 1;
      "borderThickness" = 1;
      "widgetOutlineEnabled" = false;
      "widgetOutlineColor" = "primary";
      "widgetOutlineOpacity" = 1;
      "widgetOutlineThickness" = 1;
      "fontScale" = 1;
      "iconScale" = 1;
      "autoHide" = false;
      "autoHideStrict" = false;
      "autoHideDelay" = 250;
      "showOnWindowsOpen" = false;
      "openOnOverview" = false;
      "visible" = true;
      "popupGapsAuto" = true;
      "popupGapsManual" = 4;
      "maximizeDetection" = true;
      "useOverlayLayer" = false;
      "scrollEnabled" = true;
      "scrollXBehavior" = "column";
      "scrollYBehavior" = "workspace";
      "shadowIntensity" = 0;
      "shadowOpacity" = 60;
      "shadowColorMode" = "default";
      "shadowCustomColor" = "#000000";
      "clickThrough" = false;
      "hoverPopouts" = false;
      "hoverPopoutDelay" = 150;
      "island" = true;
      "islandHomeLayout" = [
        {
          "id" = "media";
          "enabled" = true;
        }
        {
          "id" = "clock";
          "enabled" = true;
        }
        {
          "id" = "notifications";
          "enabled" = true;
        }
        {
          "id" = "weather";
          "enabled" = false;
        }
        {
          "id" = "status";
          "enabled" = false;
        }
        {
          "id" = "volume";
          "enabled" = false;
        }
        {
          "id" = "brightness";
          "enabled" = false;
        }
      ];
      "islandTransparency" = 0.5;
      "islandFloating" = false;
      "islandNotificationExpand" = true;
    }
  ];
  "desktopClockCustomColor" = {
    "r" = 1;
    "g" = 1;
    "b" = 1;
    "a" = 1;
    "hsvHue" = -1;
    "hsvSaturation" = 0;
    "hsvValue" = 1;
    "hslHue" = -1;
    "hslSaturation" = 0;
    "hslLightness" = 1;
    "valid" = true;
    "rgba" = -1;
  };
  "systemMonitorCustomColor" = {
    "r" = 1;
    "g" = 1;
    "b" = 1;
    "a" = 1;
    "hsvHue" = -1;
    "hsvSaturation" = 0;
    "hsvValue" = 1;
    "hslHue" = -1;
    "hslSaturation" = 0;
    "hslLightness" = 1;
    "valid" = true;
    "rgba" = -1;
  };
  "builtInPluginSettings" = {
    "dms_settings_search" = {
      "trigger" = "?";
    };
    "dms_clipboard_search" = {
      "trigger" = "cb";
    };
    "dms_power" = {
      "trigger" = "pw";
    };
    "dms_qr_generator" = {
      "trigger" = "qrg";
    };
  };
  "configVersion" = 18;
}
// {
  lockPamExternallyManaged = true;
  customThemeFile = "${configHome}/dms/themes/catppuccin/theme.json";
}
