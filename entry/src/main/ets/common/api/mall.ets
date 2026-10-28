// 车主商城（自定义功能 C4）：商品列表 + 收藏 + 产品评价
// 说明：商城为课程要求的自定义扩展，后端暂无对应接口，固定走本地数据；
// 若后续提供接口，改为 post(ApiPath.mallList, ...) 即可，页面层无需改动。
import { MallProduct } from '../model/MallBean'
import { mockGetMallList, mockToggleFav } from '../utils/MockData'

export function getMallList(): Promise<MallProduct[]> {
  return mockGetMallList()
}

// 收藏切换：本地数据即时生效
export function toggleFav(id: string): Promise<boolean> {
  return mockToggleFav(id)
}
