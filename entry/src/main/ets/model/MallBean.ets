// 车主商城 Bean（自定义功能 C4）：商品 + 评价
export class Review {
  user: string = ''
  rating: number = 5 // 1–5 星
  content: string = ''
  time: string = ''
}

export class MallProduct {
  id: string = ''
  name: string = ''
  price: number = 0 // 现价
  originalPrice: number = 0 // 原价（用于优惠划线）
  discount: string = '' // 优惠文案，如"满199减30"
  desc: string = ''
  sales: number = 0 // 销量
  fav: boolean = false // 是否已收藏
  tag: string = '' // 角标，如"车主专享"
  reviews: Review[] = []
}

// 服务器 JSON → 商品数组（目前商城走本地数据，保留解析便于后续接接口）
export function parseMallList(data: ESObject): MallProduct[] {
  const list: MallProduct[] = []
  if (data === undefined || data === null) {
    return list
  }
  const rows: ESObject[] = (data as ESObject[]) ?? []
  for (let i: number = 0; i < rows.length; i++) {
    const d: ESObject = rows[i] as ESObject
    const p: MallProduct = new MallProduct()
    p.id = (d['id'] as string) ?? ''
    p.name = (d['name'] as string) ?? ''
    p.price = (d['price'] as number) ?? 0
    p.originalPrice = (d['originalPrice'] as number) ?? 0
    p.discount = (d['discount'] as string) ?? ''
    p.desc = (d['desc'] as string) ?? ''
    p.sales = (d['sales'] as number) ?? 0
    p.fav = (d['fav'] as boolean) ?? false
    p.tag = (d['tag'] as string) ?? ''
    const reviews: ESObject[] = (d['reviews'] as ESObject[]) ?? []
    for (let j: number = 0; j < reviews.length; j++) {
      const r: ESObject = reviews[j] as ESObject
      const review: Review = new Review()
      review.user = (r['user'] as string) ?? ''
      review.rating = (r['rating'] as number) ?? 5
      review.content = (r['content'] as string) ?? ''
      review.time = (r['time'] as string) ?? ''
      p.reviews.push(review)
    }
    list.push(p)
  }
  return list
}
