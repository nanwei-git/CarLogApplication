import { preferences, ValueType } from '@kit.ArkData'

class PreferenceClass {
  private context: Context | null = null; // 上下文
  private storeName: string = 'defaultStore'

  // 获取上下文：从 AppStorage 里拿 UIContext，再取其 Context
  private getMyContext(): Context | undefined {
    if (this.context) {
      return this.context
    }
    const uiContext = AppStorage.get('UIContext') as UIContext | undefined
    const context = uiContext?.getHostContext()
    if (context) {
      this.context = context
    }
    return context
  }

  //   1、创建仓库
  async getStore(storeName: string = this.storeName): Promise<preferences.Preferences | undefined> {
    const context = this.getMyContext()
    if (!context) {
      console.error('getStore failed: context is undefined')
      return undefined
    }
    try {
      const store = preferences.getPreferencesSync(context, { name: storeName })
      return store
    } catch (e) {
      console.error('getStore failed: ' + JSON.stringify(e))
      return undefined
    }
  }

  //   2、设置仓库里面的内容
  async setStoreContent(myStoreName: string, key: string, value: ValueType) {
    // 获取仓库
    const store = await this.getStore(myStoreName)
    if (!store) {
      return
    }
    try {
      //  设置内容
      store.putSync(key, value)
      store.flush()
    } catch (e) {
      console.error('setStoreContent failed: ' + JSON.stringify(e))
    }
  }

  //   3、查询仓库中的内容
  async getStoreContent(myStoreName: string, myKey: string, myValue: ValueType) {
    //   获取仓库
    const store = await this.getStore(myStoreName)
    if (!store) {
      return myValue
    }
    try {
      //   查询内容
      const result = store.getSync(myKey, myValue)
      return result
    } catch (e) {
      console.error('getStoreContent failed: ' + JSON.stringify(e))
      return myValue
    }
  }

  //   4、删除仓库里的内容
  async delStoreContent(myStoreName: string, myKey: string) {
    //   获取仓库
    const store = await this.getStore(myStoreName)
    if (!store) {
      return
    }
    try {
      //   删除内容
      store.deleteSync(myKey)
      store.flush()
    } catch (e) {
      console.error('delStoreContent failed: ' + JSON.stringify(e))
    }
  }
}

export let preferenceClass = new PreferenceClass();
