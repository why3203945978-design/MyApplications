import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    console.log('EntryAbility onCreate');
  }

  onDestroy() {
    console.log('EntryAbility onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // Load content first, then configure window properties after content is loaded
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        console.error('Failed to load the content. Cause: ' + JSON.stringify(err));
        return;
      }
      
      // Now that content is loaded, safely configure window properties
      windowStage.getMainWindow((err, window) => {
        if (err.code) {
          console.error('Failed to obtain the main window. Cause: ' + JSON.stringify(err));
          return;
        }

        // Set window background color after content is loaded
        window.setWindowBackgroundColor('#FFFFFF');
        window.setWindowSystemBarProperties({
          statusBarColor: '#FFFFFF',
          navigationBarColor: '#FFFFFF',
          isStatusBarLightIcon: true
        });
      });
    });
  }

  onWindowStageRestore(windowStage: window.WindowStage) {
  }

  onForeground() {
  }

  onBackground() {
  }
}