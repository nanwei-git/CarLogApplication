import { promptAction } from '@kit.ArkUI';
import { preferenceClass } from './common/utils/PreferenceClass';

const STORE_NAME: string = 'fontSizeStore';
const FONT_SIZE_KEY: string = 'fontSize';
const DEFAULT_FONT_SIZE: number = 14;

@Entry
@Component
struct FonuSizePreferencesPage {
  @State
  fontSize: number = DEFAULT_FONT_SIZE;

  aboutToAppear(): void {
    // 打开页面时读取已保存的字体大小
    this.loadFontSize();
  }

  private async loadFontSize(): Promise<void> {
    try {
      const value = await preferenceClass.getStoreContent(STORE_NAME, FONT_SIZE_KEY, DEFAULT_FONT_SIZE);
      this.fontSize = value as number;
    } catch (e) {
      console.error('load fontSize failed: ' + JSON.stringify(e));
    }
  }

  // 写入用户首选项并立即落盘，保证下次打开仍然生效
  private async saveFontSize(size: number): Promise<void> {
    try {
      await preferenceClass.setStoreContent(STORE_NAME, FONT_SIZE_KEY, size);
    } catch (e) {
      console.error('save fontSize failed: ' + JSON.stringify(e));
    }
  }

  private async resetFontSize(): Promise<void> {
    try {
      await preferenceClass.delStoreContent(STORE_NAME, FONT_SIZE_KEY);
    } catch (e) {
      console.error('reset fontSize failed: ' + JSON.stringify(e));
    }
    this.fontSize = DEFAULT_FONT_SIZE;
  }

  private showToast(message: string): void {
    try {
      promptAction.openToast({ message: message, duration: 2000 });
    } catch (e) {
      console.error('show toast failed: ' + JSON.stringify(e));
    }
  }

  build() {
    Column() {
      Text('字体大小设置：' + this.fontSize)
        .fontSize(this.fontSize)
        .height('70%')
      Slider({
        value: this.fontSize,
        min: 12,
        max: 30,
        step: 1,
        style: SliderStyle.InSet
      }).onChange((value: number, mode: SliderChangeMode) => {
        this.fontSize = value
        // 拖动结束时才写入首选项，避免频繁落盘
        if (mode === SliderChangeMode.End) {
          this.saveFontSize(value)
        }
      }).layoutWeight(1)
        .width('100%')
        .padding({ left: 20, right: 20 })
      Column({ space: 10 }) {
        Button('用户首选项设置字体大小').onClick(() => {
          this.saveFontSize(this.fontSize)
          this.showToast('已保存：' + this.fontSize)
        })
        Button('恢复初始值').onClick(() => {
          this.resetFontSize()
        })
      }
      .padding({ bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
