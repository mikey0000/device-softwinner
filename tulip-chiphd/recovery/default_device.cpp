/*
 * Copyright (C) 2015 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "device.h"
#include "roots.h"
#include "screen_ui.h"
#include <unistd.h>

#define AW_UP            114
#define AW_DOWN          115
#define KEY_POWER        116

#define FIRST_BOOT_FLAG "/bootloader/data.notfirstrun"

class AwDevice : public Device {

  public:
    AwDevice(RecoveryUI* ui) :
        Device(ui) {
    }

    int HandleMenuKey(int key, int visible) {
      if (!visible) {
        return kNoAction;
      }

      int result = Device::HandleMenuKey(key, visible);
      if (result != kNoAction) {
        return result;
      }

      switch (key) {
        case KEY_DOWN:
        case AW_UP:
          return kHighlightDown;

        case KEY_UP:
        case AW_DOWN:
          return kHighlightUp;

        case KEY_ENTER:
        case KEY_POWER:
          return kInvokeItem;

        default:
          return kNoAction;
      }
    }

    bool PostWipeData() {
        ensure_path_mounted(FIRST_BOOT_FLAG);
        unlink(FIRST_BOOT_FLAG);
        return true;
    }
};

Device* make_device() {
  return new AwDevice(new ScreenRecoveryUI);
}
