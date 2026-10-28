@Entry
@Component
struct YqhNavigationPage {
  @State message: string = '页面';
  // 1、创建并配置NavPathStack对象
  //交给NavPathStack管理组件跳转
  navPathStack: NavPathStack = new NavPathStack();
  @Builder pageMap(name:string){
    if(name === 'yqhSecondPage'){
      NavDestination(){
        Column(){
          Text('第二个页面')
            .fontSize(36)
            .fontWeight(FontWeight.Bolder)
            .fontColor(Color.Blue)
          Button('第三界面')
            .onClick(()=>{
              this.navPathStack.pushPath({name:'yqhThirdPage'})
            })
        }
      }.title('第二界面')
    }else if(name === 'yqhThirdPage'){
      NavDestination(){
        Column(){
          Text('第三个页面')
            .fontSize(46)
            .fontColor(Color.Green)
        }
      }.title('第三界面')
    }
  }

  build() {
    // 2由Navgation导航组件监听导航变化

    Navigation(this.navPathStack) {
      Column() {
        Text(this.message)
          .fontSize(36)
          .fontWeight(FontWeight.Bolder)
        Button("跳转到第二组件")
          .onClick(() => {
            // 2.1 调用NavPathStack对象的pushPath方法，传入跳转的路径
            this.navPathStack.pushPath({name:'yqhSecondPage'})
          })

      }
    }.navDestination(this.pageMap)
    // 3告诉跳转的组件，跳转的路径
  }
}