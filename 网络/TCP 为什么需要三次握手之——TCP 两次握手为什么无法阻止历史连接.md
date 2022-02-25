# TCP 为什么需要三次握手之——TCP 两次握手为什么无法阻止历史连接

大家好，我是小林。

之前我在图解网络 PDF 里写「TCP 为什么需要三次握手？」，给出了三个原因：

- 三次握手才可以阻止历史连接的初始化（主要原因）；
- 三次握手才可以同步双方的初始序列号；
- 三次握手才可以避免资源浪费；

同时，这个内容也在知乎得到了 1000 多赞。



![图片](https://mmbiz.qpic.cn/mmbiz_png/J0g14CUwaZeqXGAtbtaZctd5Uv53UlnIZroUVgJskdlgJopRzRG0x4XufrRfmSE80nVibj5yeHymKWKxZeMynsA/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

其中，在讲第一个原因的时候，提到「*三次握手可以通过上下文判断当前连接是否是历史连接，而两次握手无法判断*」。

因为当时没有详细说为什么两次握手无法判断历史连接，导致有很多读者私信我这个问题。

![图片](https://mmbiz.qpic.cn/mmbiz_png/J0g14CUwaZfDWoRQ7jZygPyEH4QSX8ZjHt6hacfwmDGnmenk3oZ7fZ7tkkfKCpLf1FR17BiadLiczL3ledulNsyQ/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

所以，这次详细说一下，顺便给大家复习下，这个面试被问到发霉的问题。

### TCP 两次握手为什么无法阻止历史连接？

我之前的图解网络 PDF  里写的是，两次握手**无法判断历史连接**。

其实这句话，不太准确，因为就像读者问的那样，第二次握手的时候，客户端也可以根据他的序列号和收到的报文中的确认号进行比较。

所以，应该改成「TCP 两次握手**无法阻止历史连接**」。

那为什么 TCP 两次握手为什么无法阻止历史连接呢？

我先直接说结论，主要是因为**在两次握手的情况下，「被动发起方」没有中间状态给「主动发起方」来阻止历史连接，导致「被动发起方」可能建立一个历史连接，造成资源浪费**。

你想想，两次握手的情况下，「被动发起方」在收到 SYN 报文后，就进入 ESTABLISHED 状态，意味着这时可以给对方发送数据给，但是「主动发」起方此时还没有进入 ESTABLISHED 状态，假设这次是历史连接，主动发起方判断到此次连接为历史连接，那么就会回 RST 报文来断开连接，而「被动发起方」在第一次握手的时候就进入 ESTABLISHED 状态，所以它可以发送数据的，但是它并不知道这个是历史连接，它只有在收到 RST 报文后，才会断开连接。

![图片](https://mmbiz.qpic.cn/mmbiz_png/J0g14CUwaZfDWoRQ7jZygPyEH4QSX8Zjds1ia3viaIZBEEzBRAhMpLVTqcgQ6330XOLREM1gDAMKxvGIOBYiafwrA/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

可以看到，上面这种场景下，「被动发起方」在向「主动发起方」发送数据前，并没有阻止掉历史连接，导致「被动发起方」建立了一个历史连接，又白白发送了数据，妥妥地浪费了「被动发起方」的资源。

因此，**要解决这种现象，最好就是在「被动发起方」发送数据前，也就是建立连接之前，要阻止掉历史连接，这样就不会造成资源浪费，而要实现这个功能，就需要三次握手**。

三次握手阻止历史连接的过程如下图，注意图中的两个连接的序列号是不一样的，因此新旧 SYN 报文并不是发生了超时重传，两个都是独立的连接。

![图片](https://mmbiz.qpic.cn/mmbiz_png/J0g14CUwaZfDWoRQ7jZygPyEH4QSX8ZjSAnNeZA1l5pib1sg9NEObxvQf1hcTib6BqEiaic4nBtv3FeVG8jSaia6p0Q/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

客户端连续发送多次 SYN 建立连接的报文，在网络拥堵情况下:

- 一个「旧 SYN 报文」比「最新的 SYN 」 报文早到达了服务端;
- 那么此时服务端就会回一个 SYN + ACK 报文给客户端;
- 客户端收到后可以根据自身的上下文，判断这是一个历史连接（序列号过期），那么客户端就会发送 RST 报文给服务端，表示中止这一次连接。

可以看到，**在三次握手的情况下， 可以在服务端建立连接之前，可以阻止掉了历史连接，从而保证建立的连接不是历史连接**。