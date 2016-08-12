require(tseries)
require(arules)
require(arulesViz)
require(RCurl) # base64Encode

require(RJSONIO)

# CART決策樹
require(rpart)
require(rpart.plot)

maintitanic <- function (jsonObj){

  o = fromJSON(jsonObj)
  load(o["rawdata"])

  rule <- apriori(titanic.raw,
                # min support & confidence, 最小規則長度(lhs+rhs)
                parameter=list(minlen=3, supp=0.1, conf=0.7),
                appearance = list(default="lhs",
                                  rhs=c("Survived=No", "Survived=Yes")
                                  # 右手邊顯示的特徵
                                  )
                )

  sort.rule <- sort(rule, by="lift")
  subset.matrix <- is.subset(x=sort.rule, y=sort.rule)
  # 把這個矩陣的下三角去除，只留上三角的資訊
  subset.matrix[lower.tri(subset.matrix, diag=T)] <- NA


  # 計算每個column中TRUE的個數，若有一個以上的TRUE，代表此column是多餘的
  redundant <- colSums(subset.matrix, na.rm=T) >= 1

  # 移除多餘的規則
  sort.rule <- sort.rule[!redundant]

  png(tf1 <- tempfile(fileext = ".png"), width = 500, height = 500, units = "px")
  plot(sort.rule)
  dev.off()


  # 決策樹
  # 先把資料區分成 train=0.8, test=0.2
  set.seed(22)
  train.index <- sample(x=1:nrow(titanic.raw), size=ceiling(0.8*nrow(titanic.raw) ))
  train <- titanic.raw[train.index, ]
  test <- titanic.raw[-train.index, ]

  # CART的模型：把存活與否的變數(Survived)當作Y，剩下的變數當作X
  cart.model<- rpart(Survived ~. , data=train)


  png(tf2 <- tempfile(fileext = ".png"), width = 500, height = 500, units = "px")
  prp(cart.model,         # 模型
      faclen=0,           # 呈現的變數不要縮寫
      fallen.leaves=TRUE, # 讓樹枝以垂直方式呈現
      shadow.col="gray",  # 最下面的節點塗上陰影
      # number of correct classifications / number of observations in that node
      extra=2)
  dev.off()

  tf1png <- base64Encode(readBin(tf1, "raw", file.info(tf1)[1, "size"]), "txt")
  tf2png <- base64Encode(readBin(tf2, "raw", file.info(tf2)[1, "size"]), "txt")
  returnObj <- list(ruleviz=tf1png, cart=tf2png, rule=inspect(sort.rule))

  return (toJSON(returnObj))
}

testjson <- function (jsonObj) {

  o <- fromJSON(jsonObj)
  o <- do.call(rbind, lapply(o, data.frame, stringsAsFactors=FALSE))

  drops <- c("field1")
  o <- o[ , !(names(o) %in% drops)]

  # to Factor
  col_names <- names(o)
  o[,col_names] <- lapply(o[,col_names] , factor)

  titanic.raw <- o


  rule <- apriori(titanic.raw,
                # min support & confidence, 最小規則長度(lhs+rhs)
                parameter=list(minlen=3, supp=0.1, conf=0.7),
                appearance = list(default="lhs",
                                  rhs=c("Survived=No", "Survived=Yes")
                                  # 右手邊顯示的特徵
                                  )
                )

  sort.rule <- sort(rule, by="lift")
  subset.matrix <- is.subset(x=sort.rule, y=sort.rule)
  # 把這個矩陣的下三角去除，只留上三角的資訊
  subset.matrix[lower.tri(subset.matrix, diag=T)] <- NA


  # 計算每個column中TRUE的個數，若有一個以上的TRUE，代表此column是多餘的
  redundant <- colSums(subset.matrix, na.rm=T) >= 1

  # 移除多餘的規則
  sort.rule <- sort.rule[!redundant]

  png(tf1 <- tempfile(fileext = ".png"), width = 500, height = 500, units = "px")
  plot(sort.rule)
  dev.off()


  # 決策樹
  # 先把資料區分成 train=0.8, test=0.2
  set.seed(22)
  train.index <- sample(x=1:nrow(titanic.raw), size=ceiling(0.8*nrow(titanic.raw) ))
  train <- titanic.raw[train.index, ]
  test <- titanic.raw[-train.index, ]

  # CART的模型：把存活與否的變數(Survived)當作Y，剩下的變數當作X
  cart.model<- rpart(Survived ~. , data=train)


  png(tf2 <- tempfile(fileext = ".png"), width = 500, height = 500, units = "px")
  prp(cart.model,         # 模型
      faclen=0,           # 呈現的變數不要縮寫
      fallen.leaves=TRUE, # 讓樹枝以垂直方式呈現
      shadow.col="gray",  # 最下面的節點塗上陰影
      # number of correct classifications / number of observations in that node
      extra=2)
  dev.off()

  tf1png <- base64Encode(readBin(tf1, "raw", file.info(tf1)[1, "size"]), "txt")
  tf2png <- base64Encode(readBin(tf2, "raw", file.info(tf2)[1, "size"]), "txt")

  returnObj <- list(ruleviz=tf1png, cart=tf2png, rule=inspect(sort.rule))

  return (toJSON(returnObj))
}