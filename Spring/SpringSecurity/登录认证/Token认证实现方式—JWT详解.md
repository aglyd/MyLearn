# 一、[JWT详解](https://www.baobao555.tech/posts/4cc42459/)

# JWT简介

## 1.什么是JWT

在介绍JWT之前，我们先来回顾一下利用`token`进行用户身份验证的流程：

1. 客户端使用用户名和密码请求登录
2. 服务端收到请求，验证用户名和密码
3. 验证成功后，服务端会签发一个`token`，再把这个`token`返回给客户端
4. 客户端收到token后可以把它存储起来，比如放到cookie中
5. 客户端每次向服务端请求资源时需要携带服务端签发的token，可以在`cookie`或者`header`中携带
6. 服务端收到请求，然后去验证客户端请求里面带着的`token`，如果验证成功，就向客户端返回请求数据

这种基于`token`的认证方式相比传统的`session`认证方式更节约服务器资源，并且对移动端和分布式更加友好。其优点如下：

- **支持跨域访问**：`cookie`是无法跨域的，而`token`由于没有用到`cookie`(前提是将`token`放到请求头中)，所以跨域后不会存在信息丢失问题
- **无状态**：`token`机制在服务端不需要存储`session`信息，因为token自身包含了所有登录用户的信息，所以可以减轻服务端压力
- **更适用CDN**：可以通过内容分发网络请求服务端的所有资料
- **更适用于移动端**：当客户端是非浏览器平台时，`cookie`是不被支持的，此时采用`token`认证方式会简单很多
- **无需考虑CSRF**：由于不再依赖`cookie`，所以采用token认证方式不会发生CSRF，所以也就无需考虑CSRF的防御



而`JWT`就是上述流程当中`token`的一种具体实现方式，其全称是`JSON Web Token`，官网地址：https://jwt.io/

通俗地说，**JWT的本质就是一个字符串**，它是将用户信息保存到一个Json字符串中，然后进行编码后得到一个`JWT token`，**并且这个`JWT token`带有签名信息，接收后可以校验是否被篡改**，所以可以用于在各方之间安全地将信息作为Json对象传输。JWT的认证流程如下：

1. 首先，前端通过Web表单将自己的用户名和密码发送到后端的接口，这个过程一般是一个`POST`请求。建议的方式是通过SSL加密的传输(HTTPS)，从而避免敏感信息被嗅探
2. 后端核对用户名和密码成功后，**将包含用户信息的数据作为JWT的Payload，将其与JWT Header分别进行Base64编码拼接后签名**，形成一个`JWT Token`，形成的`JWT Token`就是一个如同`lll.zzz.xxx`的字符串
3. 后端将`JWT Token`字符串作为登录成功的结果返回给前端。前端可以将返回的结果保存在浏览器中，退出登录时删除保存的`JWT Token`即可
4. **前端在每次请求时将`JWT Token`放入HTTP请求头中的`Authorization`属性中**(解决XSS和XSRF问题)
5. 后端检查前端传过来的`JWT Token`，验证其有效性，比如检查签名是否正确、是否过期、token的接收方是否是自己等等
6. 验证通过后，后端解析出`JWT Token`中包含的用户信息，进行其他逻辑操作(一般是根据用户信息得到权限等)，返回结果

![img](https://gitee.com/coder-baobao/blogpic/raw/master/image-20210626223811598.png)

## 2.为什么要用JWT

### 2.1 传统Session认证的弊端

我们知道**HTTP本身是一种无状态的协议**，这就意味着如果用户向我们的应用提供了用户名和密码来进行用户认证，认证通过后HTTP协议不会记录下认证后的状态，那么下一次请求时，用户还要再一次进行认证，因为根据HTTP协议，我们并不知道是哪个用户发出的请求，所以为了让我们的应用能识别是哪个用户发出的请求，我们只能在用户首次登录成功后，在服务器存储一份用户登录的信息，这份登录信息会在响应时传递给浏览器，告诉其保存为`cookie`，以便下次请求时发送给我们的应用，这样我们的应用就能识别请求来自哪个用户了，这是传统的基于`session`认证的过程

![img](https://gitee.com/coder-baobao/blogpic/raw/master/image-20210626202225399.png)

然而，传统的`session`认证有如下的问题：

- 每个用户的登录信息都会保存到服务器的`session`中，**随着用户的增多，服务器开销会明显增大**
- 由于`session`是存在与服务器的物理内存中，所以**在分布式系统中，这种方式将会失效**。虽然可以将`session`统一保存到Redis中，但是这样做无疑增加了系统的复杂性，对于不需要redis的应用也会白白多引入一个缓存中间件
- **对于非浏览器的客户端、手机移动端等不适用**，因为`session`依赖于`cookie`，而移动端经常没有`cookie`
- 因为`session`认证本质基于`cookie`，所以如果`cookie`被截获，用户很容易收到跨站请求伪造攻击。并且如果浏览器禁用了`cookie`，这种方式也会失效
- 前后端分离系统中更加不适用，后端部署复杂，前端发送的请求往往经过多个中间件到达后端，`cookie`中关于`session`的信息会转发多次
- 由于基于Cookie，而**cookie无法跨域，所以session的认证也无法跨域，对单点登录不适用**

### 2.2 JWT认证的优势

对比传统的`session`认证方式，JWT的优势是：

- 简洁：`JWT Token`数据量小，传输速度也很快
- 因为JWT Token是以JSON加密形式保存在客户端的，所以JWT是**跨语言**的，原则上任何web形式都支持
- 不需要在服务端保存会话信息，也就是说**不依赖于cookie和session，所以没有了传统session认证的弊端，特别适用于分布式微服务**
- **单点登录友好**：使用Session进行身份认证的话，由于cookie无法跨域，难以实现单点登录。但是，使用token进行认证的话， **token可以被保存在客户端的任意位置的内存中，不一定是cookie，所以不依赖cookie**，不会存在这些问题
- **适合移动端应用**：使用Session进行身份认证的话，需要保存一份信息在服务器端，而且这种方式会依赖到Cookie（需要 Cookie 保存 SessionId），所以不适合移动端

> 因为这些优势，目前无论单体应用还是分布式应用，都更加**推荐用JWT token的方式进行用户认证**

# JWT结构

JWT由3部分组成：标头(Header)、有效载荷(Payload)和签名(Signature)。在传输的时候，会将JWT的3部分分别进行Base64编码后用`.`进行连接形成最终传输的字符串
$$
JWTString = Base64(Header).Base64(Payload).HMACSHA256(base64UrlEncode(header) + “.” + base64UrlEncode(payload), secret)
$$
![img](https://gitee.com/coder-baobao/blogpic/raw/master/image-20200912222235276.png)

## 1.Header

**JWT头**是一个描述JWT元数据的JSON对象，alg属性表示签名使用的算法，默认为HMAC SHA256（写为HS256）；typ属性表示令牌的类型，JWT令牌统一写为JWT。最后，使用Base64 URL算法将上述JSON对象转换为字符串保存

```yaml
{
  "alg": "HS256",
  "typ": "JWT"
}
```

## 2.Payload

**有效载荷**部分，是JWT的主体内容部分，也是一个**JSON对象**，包含需要传递的数据。 JWT指定七个默认字段供选择

```yaml
iss：发行人
exp：到期时间
sub：主题
aud：用户
nbf：在此之前不可用
iat：发布时间
jti：JWT ID用于标识该JWT
```

除以上默认字段外，我们还可以自定义私有字段，**一般会把包含用户信息的数据放到payload中**，如下例：

```yaml
{
  "sub": "1234567890",
  "name": "Helen",
  "admin": true
}
```

> 请注意，**默认情况下JWT是未加密的，因为只是采用base64算法，拿到JWT字符串后可以转换回原本的JSON数据，任何人都可以解读其内容，因此不要构建隐私信息字段，比如用户的密码一定不能保存到JWT中**，以防止信息泄露。**JWT只是适合在网络中传输一些非敏感的信息**

## 3.Signature

**签名哈希**部分是对上面两部分数据签名，需要使用base64编码后的header和payload数据，通过指定的算法生成哈希，以**确保数据不会被篡改**。首先，需要指定一个密钥（secret）。该密码仅仅为保存在服务器中，并且不能向用户公开。然后，使用header中指定的签名算法（默认情况下为HMAC SHA256）根据以下公式生成签名
$$
HMACSHA256(base64UrlEncode(header) + “.” + base64UrlEncode(payload), secret)
$$
在计算出签名哈希后，JWT头，有效载荷和签名哈希的三个部分组合成一个字符串，每个部分用`.`分隔，就构成整个JWT对象

![img](https://gitee.com/coder-baobao/blogpic/raw/master/image-20200912220832713.png)

> 注意JWT每部分的作用，在服务端接收到客户端发送过来的JWT token之后：
>
> - `header`和`payload`可以直接利用base64解码出原文，从`header`中获取哈希签名的算法，从`payload`中获取有效数据
> - `signature`由于使用了不可逆的加密算法，无法解码出原文，它的作用是**校验token有没有被篡改**。服务端获取`header`中的加密算法之后，利用该算法加上`secretKey`对`header`、`payload`进行加密，比对加密后的数据和客户端发送过来的是否一致。注意`secretKey`只能保存在服务端，而且对于不同的加密算法其含义有所不同，一般对于MD5类型的摘要加密算法，`secretKey`实际上代表的是盐值

# JWT的种类

其实JWT(JSON Web Token)指的是一种规范，这种规范允许我们使用JWT在两个组织之间传递安全可靠的信息，JWT的具体实现可以分为以下几种：

- `nonsecure JWT`：未经过签名，不安全的JWT
- `JWS`：经过签名的JWT
- `JWE`：`payload`部分经过加密的JWT

\##1.nonsecure JWT

未经过签名，不安全的JWT。其`header`部分没有指定签名算法

```yaml
{
  "alg": "none",
  "typ": "JWT"
}
```

并且也没有`Signature`部分

## 2.JWS

JWS ，也就是JWT Signature，其结构就是在之前nonsecure JWT的基础上，在头部声明签名算法，并在最后添加上签名。**创建签名，是保证jwt不能被他人随意篡改**。我们通常使用的JWT一般都是JWS

为了完成签名，除了用到header信息和payload信息外，还需要算法的密钥，也就是`secretKey`。加密的算法一般有2类：

- 对称加密：`secretKey`指加密密钥，可以生成签名与验签
- 非对称加密：`secretKey`指私钥，只用来生成签名，不能用来验签(验签用的是公钥)

JWT的密钥或者密钥对，一般统一称为JSON Web Key，也就是`JWK`

到目前为止，jwt的签名算法有三种：

- HMAC【哈希消息验证码(对称)】：HS256/HS384/HS512
- RSASSA【RSA签名算法(非对称)】（RS256/RS384/RS512）
- ECDSA【椭圆曲线数据签名算法(非对称)】（ES256/ES384/ES512）

# Java中使用JWT

官网推荐了6个Java使用JWT的开源库，其中比较推荐使用的是`java-jwt`和`jjwt-root`

![img](https://gitee.com/coder-baobao/blogpic/raw/master/image-20200913093107135.png)

## 1.java-jwt

### 1.1 对称签名

首先引入依赖

```xml
<dependency>
    <groupId>com.auth0</groupId>
    <artifactId>java-jwt</artifactId>
    <version>3.10.3</version>
</dependency>
```

生成JWT的token

```java
public class JWTTest {
    @Test
    public void testGenerateToken(){
        // 指定token过期时间为10秒
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.SECOND, 10);

        String token = JWT.create()
                .withHeader(new HashMap<>())  // Header
                .withClaim("userId", 21)  // Payload
                .withClaim("userName", "baobao")
                .withExpiresAt(calendar.getTime())  // 过期时间
                .sign(Algorithm.HMAC256("!34ADAS"));  // 签名用的secret

        System.out.println(token);
    }
}
```

![img](https://gitee.com/coder-baobao/blogpic/raw/master/image-20200912224156671.png)

> 注意**多次运行方法生成的token字符串内容是不一样的**，尽管我们的payload信息没有变动。因为**JWT中携带了超时时间**，所以每次生成的token会不一样，我们利用base64解密工具可以发现payload确实携带了超时时间
>
> ![img](https://gitee.com/coder-baobao/blogpic/raw/master/image-20201004112056994.png)

解析JWT字符串

```java
@Test
public void testResolveToken(){
    // 创建解析对象，使用的算法和secret要与创建token时保持一致
    JWTVerifier jwtVerifier = JWT.require(Algorithm.HMAC256("!34ADAS")).build();	//加密的salt+算法
    // 解析指定的token
    DecodedJWT decodedJWT = jwtVerifier.verify("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyTmFtZSI6ImJhb2JhbyIsImV4cCI6MTU5OTkyMjUyOCwidXNlcklkIjoyMX0.YhA3kh9KZOAb7om1C7o3vBhYp0f61mhQWWOoCrrhqvo");
    // 获取解析后的token中的payload信息
    Claim userId = decodedJWT.getClaim("userId");
    Claim userName = decodedJWT.getClaim("userName");
    System.out.println(userId.asInt());
    System.out.println(userName.asString());
    // 输出超时时间
    System.out.println(decodedJWT.getExpiresAt());
}
```

运行后发现报异常，原因是之前生成的token已经过期

![img](https://gitee.com/coder-baobao/blogpic/raw/master/image-20200912224810668.png)

再运行一次生成token的方法，然后在过期时间10秒之内将生成的字符串拷贝到解析方法中，运行解析方法即可成功

![img](https://gitee.com/coder-baobao/blogpic/raw/master/image-20200912225551597.png)

我们可以将上述方法封装成工具类

```java
public class JWTUtils {
    // 签名密钥
    private static final String SECRET = "!DAR$";

    /**
     * 生成token
     * @param payload token携带的信息
     * @return token字符串
     */
    public static String getToken(Map<String,String> payload){
        // 指定token过期时间为7天
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.DATE, 7);

        JWTCreator.Builder builder = JWT.create();
        // 构建payload
        payload.forEach((k,v) -> builder.withClaim(k,v));
        // 指定过期时间和签名算法
        String token = builder.withExpiresAt(calendar.getTime()).sign(Algorithm.HMAC256(SECRET));
        return token;
    }


    /**
     * 解析token
     * @param token token字符串
     * @return 解析后的token
     */
    public static DecodedJWT decode(String token){
        JWTVerifier jwtVerifier = JWT.require(Algorithm.HMAC256(SECRET)).build();
        DecodedJWT decodedJWT = jwtVerifier.verify(token);
        return decodedJWT;
    }
}
```

### 1.2 非对称签名

**生成jwt串的时候需要指定私钥，解析jwt串的时候需要指定公钥**

```java
private static final String RSA_PRIVATE_KEY = "...";
private static final String RSA_PUBLIC_KEY = "...";

/**
     * 生成token
     * @param payload token携带的信息
     * @return token字符串
     */
public static String getTokenRsa(Map<String,String> payload){
    // 指定token过期时间为7天
    Calendar calendar = Calendar.getInstance();
    calendar.add(Calendar.DATE, 7);

    JWTCreator.Builder builder = JWT.create();
    // 构建payload
    payload.forEach((k,v) -> builder.withClaim(k,v));

    // 利用hutool创建RSA
    RSA rsa = new RSA(RSA_PRIVATE_KEY, null);
    // 获取私钥
    RSAPrivateKey privateKey = (RSAPrivateKey) rsa.getPrivateKey();
    // 签名时传入私钥
    String token = builder.withExpiresAt(calendar.getTime()).sign(Algorithm.RSA256(null, privateKey));
    return token;
}

/**
     * 解析token
     * @param token token字符串
     * @return 解析后的token
     */
public static DecodedJWT decodeRsa(String token){
    // 利用hutool创建RSA
    RSA rsa = new RSA(null, RSA_PUBLIC_KEY);
    // 获取RSA公钥
    RSAPublicKey publicKey = (RSAPublicKey) rsa.getPublicKey();
    // 验签时传入公钥
    JWTVerifier jwtVerifier = JWT.require(Algorithm.RSA256(publicKey, null)).build();
    DecodedJWT decodedJWT = jwtVerifier.verify(token);
    return decodedJWT;
}
```

## 2.jjwt-root

### 2.1 对称签名

引入依赖

```xml
<!-- https://mvnrepository.com/artifact/io.jsonwebtoken/jjwt -->
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt</artifactId>
    <version>0.9.1</version>
</dependency>
```

使用方法类似，可参考下列代码

```java
public class JwtUtils {
    // token时效：24小时，单位ms
    public static final long EXPIRE = 1000 * 60 * 60 * 24;
    // 签名哈希的密钥，对于不同的加密算法来说含义不同
    public static final String APP_SECRET = "ukc8BDbRigUDaY6pZFfWus2jZWLPHO";

    /**
     * 根据用户id和昵称生成token
     * @param id  用户id
     * @param nickname 用户昵称
     * @return JWT规则生成的token
     */
    public static String getJwtToken(String id, String nickname){
        String JwtToken = Jwts.builder()
                .setHeaderParam("typ", "JWT")
                .setHeaderParam("alg", "HS256")
                .setSubject("baobao-user")
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRE))
                .claim("id", id)
                .claim("nickname", nickname)
            	// HS256算法实际上就是MD5加盐值，此时APP_SECRET就代表盐值
                .signWith(SignatureAlgorithm.HS256, APP_SECRET)
                .compact();

        return JwtToken;
    }

    /**
     * 判断token是否存在与有效
     * @param jwtToken token字符串
     * @return 如果token有效返回true，否则返回false
     */
    public static boolean checkToken(String jwtToken) {
        if(StringUtils.isEmpty(jwtToken)) return false;
        try {
            Jwts.parser().setSigningKey(APP_SECRET).parseClaimsJws(jwtToken);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
        return true;
    }

    /**
     * 判断token是否存在与有效
     * @param request Http请求对象
     * @return 如果token有效返回true，否则返回false
     */
    public static boolean checkToken(HttpServletRequest request) {
        try {
            // 从http请求头中获取token字符串
            String jwtToken = request.getHeader("token");
            if(StringUtils.isEmpty(jwtToken)) return false;
            Jwts.parser().setSigningKey(APP_SECRET).parseClaimsJws(jwtToken);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
        return true;
    }

    /**
     * 根据token获取会员id
     * @param request Http请求对象
     * @return 解析token后获得的用户id
     */
    public static String getMemberIdByJwtToken(HttpServletRequest request) {
        String jwtToken = request.getHeader("token");
        if(StringUtils.isEmpty(jwtToken)) return "";
        Jws<Claims> claimsJws = Jwts.parser().setSigningKey(APP_SECRET).parseClaimsJws(jwtToken);
        Claims claims = claimsJws.getBody();
        return (String)claims.get("id");
    }
}
```

> 注意：
>
> - jjwt在0.10版本以后发生了较大变化，pom依赖要引入多个
>
>   ```java
>   <dependency>
>       <groupId>io.jsonwebtoken</groupId>
>       <artifactId>jjwt-api</artifactId>
>       <version>0.11.2</version>
>   </dependency>
>   <dependency>
>       <groupId>io.jsonwebtoken</groupId>
>       <artifactId>jjwt-impl</artifactId>
>       <version>0.11.2</version>
>       <scope>runtime</scope>
>   </dependency>
>   <dependency>
>       <groupId>io.jsonwebtoken</groupId>
>       <artifactId>jjwt-jackson</artifactId> <!-- or jjwt-gson if Gson is preferred -->
>       <version>0.11.2</version>
>       <scope>runtime</scope>
>   </dependency>
>   ```
>
> - 标准规范中对各种加密算法的`secretKey`的长度有如下要求：
>
>   - `HS256`：要求至少 256 bits (32 bytes)
>   - `HS384`：要求至少384 bits (48 bytes)
>   - `HS512`：要求至少512 bits (64 bytes)
>   - `RS256` and `PS256`：至少2048 bits
>   - `RS384` and `PS384`：至少3072 bits
>   - `RS512` and `PS512`：至少4096 bits
>   - `ES256`：至少256 bits (32 bytes)
>   - `ES384`：至少384 bits (48 bytes)
>   - `ES512`：至少512 bits (64 bytes)
>
>   在jjwt0.10版本之前，没有强制要求，`secretKey`长度不满足要求时也可以签名成功。但是0.10版本后强制要求`secretKey`满足规范中的长度要求，否则生成jws时会抛出异常
>
>   ![img](https://gitee.com/coder-baobao/blogpic/raw/master/image-20211108225429718.png)
>
>   ==新版本的jjwt中，之前的签名和验签方法都是传入密钥的字符串，已经过时。最新的方法需要传入`Key`对象==
>
>
> ```java
> public class JwtUtils {
>     // token时效：24小时
>     public static final long EXPIRE = 1000 * 60 * 60 * 24;
>     // 签名哈希的密钥，对于不同的加密算法来说含义不同
>     public static final String APP_SECRET = "ukc8BDbRigUDaY6pZFfWus2jZWLPHOsdadasdasfdssfeweee";
> 
>     /**
>      * 根据用户id和昵称生成token
>      * @param id  用户id
>      * @param nickname 用户昵称
>      * @return JWT规则生成的token
>      */
>     public static String getJwtToken(String id, String nickname){
>         String JwtToken = Jwts.builder()
>                 .setSubject("baobao-user")
>                 .setIssuedAt(new Date())
>                 .setExpiration(new Date(System.currentTimeMillis() + EXPIRE))
>                 .claim("id", id)
>                 .claim("nickname", nickname)
>                 // 传入Key对象
>                 .signWith(Keys.hmacShaKeyFor(APP_SECRET.getBytes(StandardCharsets.UTF_8)), SignatureAlgorithm.HS256)
>                 .compact();
>         return JwtToken;
>     }
> 
>     /**
>      * 判断token是否存在与有效
>      * @param jwtToken token字符串
>      * @return 如果token有效返回true，否则返回false
>      */
>     public static Jws<Claims> decode(String jwtToken) {
>         // 传入Key对象
>         Jws<Claims> claimsJws = Jwts.parserBuilder().setSigningKey(Keys.hmacShaKeyFor(APP_SECRET.getBytes(StandardCharsets.UTF_8))).build().parseClaimsJws(jwtToken);
>         return claimsJws;
>     }
> }
> ```

### 2.2 非对称签名

生成jwt串的时候需要指定私钥，解析jwt串的时候需要指定公钥

```java
private static final String RSA_PRIVATE_KEY = "...";
private static final String RSA_PUBLIC_KEY = "...";

/**
     * 根据用户id和昵称生成token
     * @param id  用户id
     * @param nickname 用户昵称
     * @return JWT规则生成的token
     */
public static String getJwtTokenRsa(String id, String nickname){
    // 利用hutool创建RSA
    RSA rsa = new RSA(RSA_PRIVATE_KEY, null);
    RSAPrivateKey privateKey = (RSAPrivateKey) rsa.getPrivateKey();
    String JwtToken = Jwts.builder()
        .setSubject("baobao-user")
        .setIssuedAt(new Date())
        .setExpiration(new Date(System.currentTimeMillis() + EXPIRE))
        .claim("id", id)
        .claim("nickname", nickname)
        // 签名指定私钥
        .signWith(privateKey, SignatureAlgorithm.RS256)
        .compact();
    return JwtToken;
}

/**
     * 判断token是否存在与有效
     * @param jwtToken token字符串
     * @return 如果token有效返回true，否则返回false
     */
public static Jws<Claims> decodeRsa(String jwtToken) {
    RSA rsa = new RSA(null, RSA_PUBLIC_KEY);
    RSAPublicKey publicKey = (RSAPublicKey) rsa.getPublicKey();
    // 验签指定公钥
    Jws<Claims> claimsJws = Jwts.parserBuilder().setSigningKey(publicKey).build().parseClaimsJws(jwtToken);
    return claimsJws;
}
```

# 实际开发中的应用

在实际的`SpringBoot`项目中，一般我们可以用如下流程做登录：

1. 在登录验证通过后，给用户生成一个对应的随机token(注意这个token不是指jwt，可以用uuid等算法生成)，然后将这个token作为key的一部分，用户信息作为value存入Redis，并设置过期时间，这个过期时间就是登录失效的时间
2. 将第1步中生成的随机token作为JWT的payload生成JWT字符串返回给前端
3. 前端之后每次请求都在请求头中的`Authorization`字段中携带JWT字符串
4. 后端定义一个拦截器，每次收到前端请求时，都先从请求头中的`Authorization`字段中取出JWT字符串并进行验证，验证通过后解析出payload中的随机token，然后再用这个随机token得到key，从Redis中获取用户信息，如果能获取到就说明用户已经登录

```java
public class JWTInterceptor implements HandlerInterceptor {
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String JWT = request.getHeader("Authorization");
        try {
            // 1.校验JWT字符串
            DecodedJWT decodedJWT = JWTUtils.decode(JWT);
            // 2.取出JWT字符串载荷中的随机token，从Redis中获取用户信息
            ...
            return true;
        }catch (SignatureVerificationException e){
            System.out.println("无效签名");
            e.printStackTrace();
        }catch (TokenExpiredException e){
            System.out.println("token已经过期");
            e.printStackTrace();
        }catch (AlgorithmMismatchException e){
            System.out.println("算法不一致");
            e.printStackTrace();
        }catch (Exception e){
            System.out.println("token无效");
            e.printStackTrace();
        }
        return false;
    }
}
```

> 在实际开发中需要用下列手段来增加JWT的安全性：
>
> - 因为JWT是在请求头中传递的，所以为了避免网络劫持，推荐使用`HTTPS`来传输，更加安全
> - JWT的哈希签名的密钥是存放在服务端的，所以只要服务器不被攻破，理论上JWT是安全的。因此要保证服务器的安全
> - JWT可以使用暴力穷举来破解，所以为了应对这种破解方式，可以定期更换服务端的哈希签名密钥(相当于盐值)。这样可以保证等破解结果出来了，你的密钥也已经换了



https://blog.csdn.net/weixin_45070175/article/details/118559272



----



# 二、[什么是 JWT -- JSON WEB TOKEN](https://www.jianshu.com/p/576dbf44b2ae)

# 什么是JWT

> Json web token (JWT), 是为了在网络应用环境间传递声明而执行的一种基于JSON的开放标准（[(RFC 7519](https://link.jianshu.com?t=https://tools.ietf.org/html/rfc7519)).该token被设计为紧凑且安全的，特别适用于分布式站点的单点登录（SSO）场景。JWT的声明一般被用来在身份提供者和服务提供者间传递被认证的用户身份信息，以便于从资源服务器获取资源，也可以增加一些额外的其它业务逻辑所必须的声明信息，该token也可直接被用于认证，也可被加密。

## 起源

说起JWT，我们应该来谈一谈基于token的认证和传统的session认证的区别。

### 传统的session认证

我们知道，http协议本身是一种无状态的协议，而这就意味着如果用户向我们的应用提供了用户名和密码来进行用户认证，那么下一次请求时，用户还要再一次进行用户认证才行，因为根据http协议，我们并不能知道是哪个用户发出的请求，所以为了让我们的应用能识别是哪个用户发出的请求，我们只能在服务器存储一份用户登录的信息，这份登录信息会在响应时传递给浏览器，告诉其保存为cookie,以便下次请求时发送给我们的应用，这样我们的应用就能识别请求来自哪个用户了,这就是传统的基于session认证。

但是这种基于session的认证使应用本身很难得到扩展，随着不同客户端用户的增加，独立的服务器已无法承载更多的用户，而这时候基于session认证应用的问题就会暴露出来.

#### 基于session认证所显露的问题

**Session**: 每个用户经过我们的应用认证之后，我们的应用都要在服务端做一次记录，以方便用户下次请求的鉴别，通常而言session都是保存在内存中，而随着认证用户的增多，服务端的开销会明显增大。

**扩展性**: 用户认证之后，服务端做认证记录，如果认证的记录被保存在内存中的话，这意味着用户下次请求还必须要请求在这台服务器上,这样才能拿到授权的资源，这样在分布式的应用上，相应的限制了负载均衡器的能力。这也意味着限制了应用的扩展能力。

**CSRF**: 因为是基于cookie来进行用户识别的, cookie如果被截获，用户就会很容易受到跨站请求伪造的攻击。

## 基于token的鉴权机制

基于token的鉴权机制类似于http协议也是无状态的，它不需要在服务端去保留用户的认证信息或者会话信息。这就意味着基于token认证机制的应用不需要去考虑用户在哪一台服务器登录了，这就为应用的扩展提供了便利。

流程上是这样的：

- 用户使用用户名密码来请求服务器
- 服务器进行验证用户的信息
- 服务器通过验证发送给用户一个token
- 客户端存储token，并在每次请求时附送上这个token值
- 服务端验证token值，并返回数据

这个token必须要在每次请求时传递给服务端，它应该保存在请求头里， 另外，服务端要支持`CORS(跨来源资源共享)`策略，一般我们在服务端这么做就可以了`Access-Control-Allow-Origin: *`。

那么我们现在回到JWT的主题上。

## JWT长什么样？

JWT是由三段信息构成的，将这三段信息文本用`.`链接一起就构成了Jwt字符串。就像这样:

```css
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ
```

## JWT的构成

第一部分我们称它为头部（header),第二部分我们称其为载荷（payload, 类似于飞机上承载的物品)，第三部分是签证（signature).

### header

jwt的头部承载两部分信息：

- 声明类型，这里是jwt
- 声明加密的算法 通常直接使用 HMAC SHA256

完整的头部就像下面这样的JSON：

```bash
{
  'typ': 'JWT',
  'alg': 'HS256'
}
```

然后将头部进行base64加密（该加密是可以对称解密的),构成了第一部分.

```undefined
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9
```

### playload

载荷就是存放有效信息的地方。这个名字像是特指飞机上承载的货品，这些有效信息包含三个部分

- 标准中注册的声明
- 公共的声明
- 私有的声明

**标准中注册的声明** (建议但不强制使用) ：

- **iss**: jwt签发者
- **sub**: jwt所面向的用户
- **aud**: 接收jwt的一方
- **exp**: jwt的过期时间，这个过期时间必须要大于签发时间
- **nbf**: 定义在什么时间之前，该jwt都是不可用的.
- **iat**: jwt的签发时间
- **jti**: jwt的唯一身份标识，主要用来作为一次性token,从而回避重放攻击。

**公共的声明** ：
 公共的声明可以添加任何的信息，一般添加用户的相关信息或其他业务需要的必要信息.但不建议添加敏感信息，因为该部分在客户端可解密.

**私有的声明** ：
 私有声明是提供者和消费者所共同定义的声明，一般不建议存放敏感信息，因为base64是对称解密的，意味着该部分信息可以归类为明文信息。

定义一个payload:

```json
{
  "sub": "1234567890",
  "name": "John Doe",
  "admin": true
}
```

然后将其进行base64加密，得到Jwt的第二部分。

```undefined
eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9
```

### signature

jwt的第三部分是一个签证信息，这个签证信息由三部分组成：

- header (base64后的)
- payload (base64后的)
- secret

这个部分需要base64加密后的header和base64加密后的payload使用`.`连接组成的字符串，然后通过header中声明的加密方式进行加盐`secret`组合加密，然后就构成了jwt的第三部分。



```csharp
// javascript
var encodedString = base64UrlEncode(header) + '.' + base64UrlEncode(payload);

var signature = HMACSHA256(encodedString, 'secret'); // TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ
```

将这三部分用`.`连接成一个完整的字符串,构成了最终的jwt:



```css
  eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ
```

**注意：secret是保存在服务器端的，jwt的签发生成也是在服务器端的，secret就是用来进行jwt的签发和jwt的验证，所以，它就是你服务端的私钥，在任何场景都不应该流露出去。一旦客户端得知这个secret, 那就意味着客户端是可以自我签发jwt了。**

### 如何应用

一般是在请求头里加入`Authorization`，并加上`Bearer`标注：



```bash
fetch('api/user/1', {
  headers: {
    'Authorization': 'Bearer ' + token
  }
})
```

服务端会验证token，如果验证通过就会返回相应的资源。整个流程就是这样的:

![img](https:////upload-images.jianshu.io/upload_images/1821058-2e28fe6c997a60c9.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

jwt-diagram

## 总结

### 优点

- 因为json的通用性，所以JWT是可以进行跨语言支持的，像JAVA,JavaScript,NodeJS,PHP等很多语言都可以使用。
- 因为有了payload部分，所以JWT可以在自身存储一些其他业务逻辑所必要的非敏感信息。
- 便于传输，jwt的构成非常简单，字节占用很小，所以它是非常便于传输的。
- 它不需要在服务端保存会话信息, 所以它易于应用的扩展

### 安全相关

- 不应该在jwt的payload部分存放敏感信息，因为该部分是客户端可解密的部分。
- 保护好secret私钥，该私钥非常重要。
- 如果可以，请使用https协议





-----

# [Spring Security + JWT 实现单点登录](https://mp.weixin.qq.com/s/5xt0i7Bwj4-Io-lYDkySug)

## 一、什么是单点登陆

单点登录（Single Sign On），简称为 SSO，是目前比较流行的企业业务整合的解决方案之一。SSO的定义是在多个应用系统中，用户只需要登录一次就可以访问所有相互信任的应用系统

## 二、简单的运行机制

[单点登录的机制其实是比较简单的，用一个现实中的例子做比较。某公园内部有许多独立的景点，游客可以在各个景点门口单独买票。](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

[对于需要游玩所有的景点的游客，这种买票方式很不方便，需要在每个景点门口排队买票，钱包拿 进拿出的，容易丢失，很不安全。](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

[于是绝大多数游客选择在大门口买一张通票（也叫套票），就可以玩遍所有的景点而不需要重新再买票。他们只需要在每个景点门 口出示一下刚才买的套票就能够被允许进入每个独立的景点。](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

[单点登录的机制也一样，如下图所示，](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

![图片](https://mmbiz.qpic.cn/mmbiz_png/mR4CwoLXicg39JnAewJBFS5nIfDvgYmu7968RqxiaiaVghshjNW4icsuaiav3owO5a82qq3TwU0BAcia6iarkntXFNmlQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

**用户认证：**这一环节主要是用户向认证服务器发起认证请求，认证服务器给用户返回一个成功的令牌token，主要在认证服务器中完成，即图中的认证系统，注意认证系统只能有一个。

**身份校验：** 这一环节是用户携带token去访问其他服务器时，在其他服务器中要对token的真伪进行检验，主要在资源服务器中完成，即图中的应用系统2 3

## 三、JWT介绍

#### 概念说明

[从分布式认证流程中，我们不难发现，这中间起最关键作用的就是token，token的安全与否，直接关系到系统的健壮性，这里我们选择使用JWT来实现token的生成和校验。](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

[JWT，全称JSON Web Token，官网地址：https://jwt.io，是一款出色的分布式身份校验方案。可以生成token，也可以解析检验token。](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

#### [JWT生成的token由三部分组成：](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

- [头部：主要设置一些规范信息，签名部分的编码格式就在头部中声明。](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)
- [载荷：token中存放有效信息的部分，比如用户名，用户角色，过期时间等，但是不要放密码，会泄露！](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)
- [签名：将头部与载荷分别采用base64编码后，用“.”相连，再加入盐，最后使用头部声明的编码类型进行编码，就得到了签名。](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

#### [JWT生成token的安全性分析](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

[从JWT生成的token组成上来看，要想避免token被伪造，主要就得看签名部分了，而签名部分又有三部分组成，其中头部和载荷的base64编码，几乎是透明的，毫无安全性可言，那么最终守护token安全的重担就落在了加入的盐上面了！](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

[试想：如果生成token所用的盐与解析token时加入的盐是一样的。岂不是类似于中国人民银行把人民币防伪技术公开了？大家可以用这个盐来解析token，就能用来伪造token。这时，我们就需要对盐采用非对称加密的方式进行加密，以达到生成token与校验token方所用的盐不一致的安全效果！](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

#### [非对称加密RSA介绍](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

**基本原理：**同时生成两把密钥：私钥和公钥，私钥隐秘保存，公钥可以下发给信任客户端

- 私钥加密，持有私钥或公钥才可以解密
- 公钥加密，持有私钥才可解密

**优点：** 安全，难以破解

**缺点：** 算法比较耗时，为了安全，可以接受

**历史：** 三位数学家Rivest、Shamir 和 Adleman 设计了一种算法，可以实现非对称加密。这种算法用他们三个人的名字缩写：RSA。最新面试题整理好了，点击[Java面试库](https://mp.weixin.qq.com/s/5xt0i7Bwj4-Io-lYDkySug)小程序在线刷题。

## 四、SpringSecurity整合JWT

### 1.认证思路分析

SpringSecurity主要是通过过滤器来实现功能的！我们要找到SpringSecurity实现认证和校验身份的过滤器！

#### 回顾集中式认证流程

**用户认证：**使用`UsernamePasswordAuthenticationFilter`过滤器中`attemptAuthentication`方法实现认证功能，该过滤器父类中`successfulAuthentication`方法实现认证成功后的操作。

**身份校验：**使用`BasicAuthenticationFilter`过滤器中`doFilterInternal`方法验证是否登录，以决定能否进入后续过滤器。

#### 分析分布式认证流程

**用户认证：**

由于分布式项目，多数是前后端分离的架构设计，我们要满足可以接受异步post的认证请求参数，需要修改`UsernamePasswordAuthenticationFilter`过滤器中`attemptAuthentication`方法，让其能够接收请求体。

另外，默认`successfulAuthentication`方法在认证通过后，是把用户信息直接放入session就完事了，现在我们需要修改这个方法，在认证通过后生成token并返回给用户。

**身份校验：**

原来BasicAuthenticationFilter过滤器中doFilterInternal方法校验用户是否登录，就是看session中是否有用户信息，我们要修改为，验证用户携带的token是否合法，并解析出用户信息，交给SpringSecurity，以便于后续的授权功能可以正常使用。

### 2.具体实现

为了演示单点登录的效果，我们设计如下项目结构

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

#### 2.1父工程创建

因为本案例需要创建多个系统，所以我们使用maven聚合工程来实现，首先创建一个父工程，导入springboot的父依赖即可。

Spring Boot 基础就不介绍了，推荐下这个实战教程：https://github.com/javastacks/spring-boot-best-practice

```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.1.3.RELEASE</version>
    <relativePath/>
</parent>
```

#### 2.2公共工程创建

然后创建一个common工程，其他工程依赖此系统

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

[**导入JWT相关的依赖**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```xml
<dependencies>
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-api</artifactId>
        <version>0.10.7</version>
    </dependency>
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-impl</artifactId>
        <version>0.10.7</version>
        <scope>runtime</scope>
    </dependency>
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-jackson</artifactId>
        <version>0.10.7</version>
        <scope>runtime</scope>
    </dependency>
    <!--jackson包-->
    <dependency>
        <groupId>com.fasterxml.jackson.core</groupId>
        <artifactId>jackson-databind</artifactId>
        <version>2.9.9</version>
    </dependency>
    <!--日志包-->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-logging</artifactId>
    </dependency>
    <dependency>
        <groupId>joda-time</groupId>
        <artifactId>joda-time</artifactId>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
    </dependency>
</dependencies>
```

[创建相关的工具类](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

[![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

[**Payload**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```java
@Data
public class Payload <T>{
    private String id;
    private T userInfo;
    private Date expiration;
}
```

[**JsonUtils**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```java
public class JsonUtils {

    public static final ObjectMapper mapper = new ObjectMapper();

    private static final Logger logger = LoggerFactory.getLogger(JsonUtils.class);

    public static String toString(Object obj) {
        if (obj == null) {
            return null;
        }
        if (obj.getClass() == String.class) {
            return (String) obj;
        }
        try {
            return mapper.writeValueAsString(obj);
        } catch (JsonProcessingException e) {
            logger.error("json序列化出错：" + obj, e);
            return null;
        }
    }

    public static <T> T toBean(String json, Class<T> tClass) {
        try {
            return mapper.readValue(json, tClass);
        } catch (IOException e) {
            logger.error("json解析出错：" + json, e);
            return null;
        }
    }

    public static <E> List<E> toList(String json, Class<E> eClass) {
        try {
            return mapper.readValue(json, mapper.getTypeFactory().constructCollectionType(List.class, eClass));
        } catch (IOException e) {
            logger.error("json解析出错：" + json, e);
            return null;
        }
    }

    public static <K, V> Map<K, V> toMap(String json, Class<K> kClass, Class<V> vClass) {
        try {
            return mapper.readValue(json, mapper.getTypeFactory().constructMapType(Map.class, kClass, vClass));
        } catch (IOException e) {
            logger.error("json解析出错：" + json, e);
            return null;
        }
    }

    public static <T> T nativeRead(String json, TypeReference<T> type) {
        try {
            return mapper.readValue(json, type);
        } catch (IOException e) {
            logger.error("json解析出错：" + json, e);
            return null;
        }
    }
}
```

[**JwtUtils**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```java
public class JwtUtils {

    private static final String JWT_PAYLOAD_USER_KEY = "user";

    /**
     * 私钥加密token
     *
     * @param userInfo 载荷中的数据
     * @param privateKey 私钥
     * @param expire 过期时间，单位分钟
     * @return JWT
     */
    public static String generateTokenExpireInMinutes(Object userInfo, PrivateKey privateKey, int expire) {
        return Jwts.builder()
                .claim(JWT_PAYLOAD_USER_KEY, JsonUtils.toString(userInfo))
                .setId(createJTI())
                .setExpiration(DateTime.now().plusMinutes(expire).toDate())
                .signWith(privateKey, SignatureAlgorithm.RS256)
                .compact();
    }

    /**
     * 私钥加密token
     *
     * @param userInfo 载荷中的数据
     * @param privateKey 私钥
     * @param expire 过期时间，单位秒
     * @return JWT
     */
    public static String generateTokenExpireInSeconds(Object userInfo, PrivateKey privateKey, int expire) {
        return Jwts.builder()
                .claim(JWT_PAYLOAD_USER_KEY, JsonUtils.toString(userInfo))
                .setId(createJTI())
                .setExpiration(DateTime.now().plusSeconds(expire).toDate())
                .signWith(privateKey, SignatureAlgorithm.RS256)
                .compact();
    }

    /**
     * 公钥解析token
     *
     * @param token 用户请求中的token
     * @param publicKey 公钥
     * @return Jws<Claims>
     */
    private static Jws<Claims> parserToken(String token, PublicKey publicKey) {
        return Jwts.parser().setSigningKey(publicKey).parseClaimsJws(token);
    }

    private static String createJTI() {
        return new String(Base64.getEncoder().encode(UUID.randomUUID().toString().getBytes()));
    }

    /**
     * 获取token中的用户信息
     *
     * @param token 用户请求中的令牌
     * @param publicKey 公钥
     * @return 用户信息
     */
    public static <T> Payload<T> getInfoFromToken(String token, PublicKey publicKey, Class<T> userType) {
        Jws<Claims> claimsJws = parserToken(token, publicKey);
        Claims body = claimsJws.getBody();
        Payload<T> claims = new Payload<>();
        claims.setId(body.getId());
        claims.setUserInfo(JsonUtils.toBean(body.get(JWT_PAYLOAD_USER_KEY).toString(), userType));
        claims.setExpiration(body.getExpiration());
        return claims;
    }

    /**
     * 获取token中的载荷信息
     *
     * @param token 用户请求中的令牌
     * @param publicKey 公钥
     * @return 用户信息
     */
    public static <T> Payload<T> getInfoFromToken(String token, PublicKey publicKey) {
        Jws<Claims> claimsJws = parserToken(token, publicKey);
        Claims body = claimsJws.getBody();
        Payload<T> claims = new Payload<>();
        claims.setId(body.getId());
        claims.setExpiration(body.getExpiration());
        return claims;
    }
}
```

[**RsaUtils**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```java
public class RsaUtils {

    private static final int DEFAULT_KEY_SIZE = 2048;
    /**
     * 从文件中读取公钥
     *
     * @param filename 公钥保存路径，相对于classpath
     * @return 公钥对象
     * @throws Exception
     */
    public static PublicKey getPublicKey(String filename) throws Exception {
        byte[] bytes = readFile(filename);
        return getPublicKey(bytes);
    }

    /**
     * 从文件中读取密钥
     *
     * @param filename 私钥保存路径，相对于classpath
     * @return 私钥对象
     * @throws Exception
     */
    public static PrivateKey getPrivateKey(String filename) throws Exception {
        byte[] bytes = readFile(filename);
        return getPrivateKey(bytes);
    }

    /**
     * 获取公钥
     *
     * @param bytes 公钥的字节形式
     * @return
     * @throws Exception
     */
    private static PublicKey getPublicKey(byte[] bytes) throws Exception {
        bytes = Base64.getDecoder().decode(bytes);
        X509EncodedKeySpec spec = new X509EncodedKeySpec(bytes);
        KeyFactory factory = KeyFactory.getInstance("RSA");
        return factory.generatePublic(spec);
    }

    /**
     * 获取密钥
     *
     * @param bytes 私钥的字节形式
     * @return
     * @throws Exception
     */
    private static PrivateKey getPrivateKey(byte[] bytes) throws NoSuchAlgorithmException, InvalidKeySpecException {
        bytes = Base64.getDecoder().decode(bytes);
        PKCS8EncodedKeySpec spec = new PKCS8EncodedKeySpec(bytes);
        KeyFactory factory = KeyFactory.getInstance("RSA");
        return factory.generatePrivate(spec);
    }

    /**
     * 根据密文，生存rsa公钥和私钥,并写入指定文件
     *
     * @param publicKeyFilename 公钥文件路径
     * @param privateKeyFilename 私钥文件路径
     * @param secret 生成密钥的密文
     */
    public static void generateKey(String publicKeyFilename, String privateKeyFilename, String secret, int keySize) throws Exception {
        KeyPairGenerator keyPairGenerator = KeyPairGenerator.getInstance("RSA");
        SecureRandom secureRandom = new SecureRandom(secret.getBytes());
        keyPairGenerator.initialize(Math.max(keySize, DEFAULT_KEY_SIZE), secureRandom);
        KeyPair keyPair = keyPairGenerator.genKeyPair();
        // 获取公钥并写出
        byte[] publicKeyBytes = keyPair.getPublic().getEncoded();
        publicKeyBytes = Base64.getEncoder().encode(publicKeyBytes);
        writeFile(publicKeyFilename, publicKeyBytes);
        // 获取私钥并写出
        byte[] privateKeyBytes = keyPair.getPrivate().getEncoded();
        privateKeyBytes = Base64.getEncoder().encode(privateKeyBytes);
        writeFile(privateKeyFilename, privateKeyBytes);
    }

    private static byte[] readFile(String fileName) throws Exception {
        return Files.readAllBytes(new File(fileName).toPath());
    }

    private static void writeFile(String destPath, byte[] bytes) throws IOException {
        File dest = new File(destPath);
        if (!dest.exists()) {
            dest.createNewFile();
        }
        Files.write(dest.toPath(), bytes);
    }
}
```

[**在通用子模块中编写测试类生成rsa公钥和私钥**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```java
public class JwtTest {
    private String privateKey = "c:/tools/auth_key/id_key_rsa";

    private String publicKey = "c:/tools/auth_key/id_key_rsa.pub";

    @Test
    public void test1() throws Exception{
        RsaUtils.generateKey(publicKey,privateKey,"dpb",1024);
    }

}
```

[![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

#### 2.3认证系统创建

[接下来我们创建我们的认证服务。](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

[**导入相关的依赖**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    <dependency>
        <artifactId>security-jwt-common</artifactId>
        <groupId>com.dpb</groupId>
        <version>1.0-SNAPSHOT</version>
    </dependency>
    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
        <version>5.1.47</version>
    </dependency>
    <dependency>
        <groupId>org.mybatis.spring.boot</groupId>
        <artifactId>mybatis-spring-boot-starter</artifactId>
        <version>2.1.0</version>
    </dependency>
    <dependency>
        <groupId>com.alibaba</groupId>
        <artifactId>druid</artifactId>
        <version>1.1.10</version>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-configuration-processor</artifactId>
        <optional>true</optional>
    </dependency>
</dependencies>
```

[**创建配置文件**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```yaml
spring:
  datasource:
    driver-class-name: com.mysql.jdbc.Driver
    url: jdbc:mysql://localhost:3306/srm
    username: root
    password: 123456
    type: com.alibaba.druid.pool.DruidDataSource
mybatis:
  type-aliases-package: com.dpb.domain
  mapper-locations: classpath:mapper/*.xml
logging:
  level:
    com.dpb: debug
rsa:
  key:
    pubKeyFile: c:\tools\auth_key\id_key_rsa.pub
    priKeyFile: c:\tools\auth_key\id_key_rsa
```

[![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

[**提供公钥私钥的配置类**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```java
package com.dpb.config;

import com.dpb.utils.RsaUtils;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

import javax.annotation.PostConstruct;
import java.security.PrivateKey;
import java.security.PublicKey;

/**
 * @program: springboot-54-security-jwt-demo
 * @description:
 * @author: 波波烤鸭
 * @create: 2019-12-03 11:25
 */
@Data
@ConfigurationProperties(prefix = "rsa.key")
public class RsaKeyProperties {

    private String pubKeyFile;
    private String priKeyFile;

    private PublicKey publicKey;
    private PrivateKey privateKey;

    /**
     * 系统启动的时候触发
     * @throws Exception
     */
    @PostConstruct
    public void createRsaKey() throws Exception {
        publicKey = RsaUtils.getPublicKey(pubKeyFile);
        privateKey = RsaUtils.getPrivateKey(priKeyFile);
    }

}
```

[**创建启动类**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```java
/**
 * @program: springboot-54-security-jwt-demo
 * @description: 启动类
 * @author: 波波烤鸭
 * @create: 2019-12-03 11:23
 */
@SpringBootApplication
@MapperScan("com.dpb.mapper")
@EnableConfigurationProperties(RsaKeyProperties.class)
public class App {

    public static void main(String[] args) {
        SpringApplication.run(App.class,args);
    }
}
```

[**完成数据认证的逻辑**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

[pojo](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```java
package com.dpb.domain;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;
import org.springframework.security.core.GrantedAuthority;

/**
 * @program: springboot-54-security-jwt-demo
 * @description:
 * @author: 波波烤鸭
 * @create: 2019-12-03 15:21
 */
@Data
public class RolePojo implements GrantedAuthority {

    private Integer id;
    private String roleName;
    private String roleDesc;

    @JsonIgnore
    @Override
    public String getAuthority() {
        return roleName;
    }
}
package com.dpb.domain;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * @program: springboot-54-security-jwt-demo
 * @description:
 * @author: 波波烤鸭
 * @create: 2019-12-03 11:33
 */
@Data
public class UserPojo implements UserDetails {

    private Integer id;

    private String username;

    private String password;

    private Integer status;

    private List<RolePojo> roles;

    @JsonIgnore
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        List<SimpleGrantedAuthority> auth = new ArrayList<>();
        auth.add(new SimpleGrantedAuthority("ADMIN"));
        return auth;
    }

    @Override
    public String getPassword() {
        return this.password;
    }

    @Override
    public String getUsername() {
        return this.username;
    }
    @JsonIgnore
    @Override
    public boolean isAccountNonExpired() {
        return true;
    }
    @JsonIgnore
    @Override
    public boolean isAccountNonLocked() {
        return true;
    }
    @JsonIgnore
    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }
    @JsonIgnore
    @Override
    public boolean isEnabled() {
        return true;
    }
}
```

[**Mapper接口**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```java
public interface UserMapper {
    public UserPojo queryByUserName(@Param("userName") String userName);
}
```

[**Mapper映射文件**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.dpb.mapper.UserMapper">
    <select id="queryByUserName" resultType="UserPojo">
        select * from t_user where username = #{userName}
    </select>
</mapper>
```

[**Service**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```java
public interface UserService extends UserDetailsService {

}


@Service
@Transactional
public class UserServiceImpl implements UserService {

    @Autowired
    private UserMapper mapper;

    @Override
    public UserDetails loadUserByUsername(String s) throws UsernameNotFoundException {
        UserPojo user = mapper.queryByUserName(s);

        return user;
    }
}
```

[**自定义认证过滤器**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```java
package com.dpb.filter;

import com.dpb.config.RsaKeyProperties;
import com.dpb.domain.RolePojo;
import com.dpb.domain.UserPojo;
import com.dpb.utils.JwtUtils;
import com.fasterxml.jackson.databind.ObjectMapper;
import net.bytebuddy.agent.builder.AgentBuilder;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @program: springboot-54-security-jwt-demo
 * @description:
 * @author: 波波烤鸭
 * @create: 2019-12-03 11:57
 */
public class TokenLoginFilter extends UsernamePasswordAuthenticationFilter {

    private AuthenticationManager authenticationManager;
    private RsaKeyProperties prop;

    public TokenLoginFilter(AuthenticationManager authenticationManager, RsaKeyProperties prop) {
        this.authenticationManager = authenticationManager;
        this.prop = prop;
    }

    public Authentication attemptAuthentication(HttpServletRequest request, HttpServletResponse response) throws AuthenticationException {
        try {
            UserPojo sysUser = new ObjectMapper().readValue(request.getInputStream(), UserPojo.class);

            UsernamePasswordAuthenticationToken authRequest = new UsernamePasswordAuthenticationToken(sysUser.getUsername(), sysUser.getPassword());
            return authenticationManager.authenticate(authRequest);
        }catch (Exception e){
            try {
                response.setContentType("application/json;charset=utf-8");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                PrintWriter out = response.getWriter();
                Map resultMap = new HashMap();
                resultMap.put("code", HttpServletResponse.SC_UNAUTHORIZED);
                resultMap.put("msg", "用户名或密码错误！");
                out.write(new ObjectMapper().writeValueAsString(resultMap));
                out.flush();
                out.close();
            }catch (Exception outEx){
                outEx.printStackTrace();
            }
            throw new RuntimeException(e);
        }
    }

    public void successfulAuthentication(HttpServletRequest request, HttpServletResponse response, FilterChain chain, Authentication authResult) throws IOException, ServletException {
        UserPojo user = new UserPojo();
        user.setUsername(authResult.getName());
        user.setRoles((List<RolePojo>)authResult.getAuthorities());
        String token = JwtUtils.generateTokenExpireInMinutes(user, prop.getPrivateKey(), 24 * 60);
        response.addHeader("Authorization", "Bearer "+token);
        try {
            response.setContentType("application/json;charset=utf-8");
            response.setStatus(HttpServletResponse.SC_OK);
            PrintWriter out = response.getWriter();
            Map resultMap = new HashMap();
            resultMap.put("code", HttpServletResponse.SC_OK);
            resultMap.put("msg", "认证通过！");
            out.write(new ObjectMapper().writeValueAsString(resultMap));
            out.flush();
            out.close();
        }catch (Exception outEx){
            outEx.printStackTrace();
        }
    }
}
```

[**自定义校验token的过滤器**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```java
package com.dpb.filter;

import com.dpb.config.RsaKeyProperties;
import com.dpb.domain.Payload;
import com.dpb.domain.UserPojo;
import com.dpb.utils.JwtUtils;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.www.BasicAuthenticationFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

/**
 * @program: springboot-54-security-jwt-demo
 * @description:
 * @author: 波波烤鸭
 * @create: 2019-12-03 12:39
 */
public class TokenVerifyFilter  extends BasicAuthenticationFilter {
    private RsaKeyProperties prop;

    public TokenVerifyFilter(AuthenticationManager authenticationManager, RsaKeyProperties prop) {
        super(authenticationManager);
        this.prop = prop;
    }

    public void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain) throws IOException, ServletException {
        String header = request.getHeader("Authorization");
        if (header == null || !header.startsWith("Bearer ")) {
            //如果携带错误的token，则给用户提示请登录！
            chain.doFilter(request, response);
            response.setContentType("application/json;charset=utf-8");
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            PrintWriter out = response.getWriter();
            Map resultMap = new HashMap();
            resultMap.put("code", HttpServletResponse.SC_FORBIDDEN);
            resultMap.put("msg", "请登录！");
            out.write(new ObjectMapper().writeValueAsString(resultMap));
            out.flush();
            out.close();
        } else {
            //如果携带了正确格式的token要先得到token
            String token = header.replace("Bearer ", "");
            //验证tken是否正确
            Payload<UserPojo> payload = JwtUtils.getInfoFromToken(token, prop.getPublicKey(), UserPojo.class);
            UserPojo user = payload.getUserInfo();
            if(user!=null){
                UsernamePasswordAuthenticationToken authResult = new UsernamePasswordAuthenticationToken(user.getUsername(), null, user.getAuthorities());
                SecurityContextHolder.getContext().setAuthentication(authResult);
                chain.doFilter(request, response);
            }
        }
    }

}
```

[**编写SpringSecurity的配置类**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```java
package com.dpb.config;

import com.dpb.filter.TokenLoginFilter;
import com.dpb.filter.TokenVerifyFilter;
import com.dpb.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * @program: springboot-54-security-jwt-demo
 * @description:
 * @author: 波波烤鸭
 * @create: 2019-12-03 12:41
 */
@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(securedEnabled=true)
public class WebSecurityConfig   extends WebSecurityConfigurerAdapter {

    @Autowired
    private UserService userService;

    @Autowired
    private RsaKeyProperties prop;

    @Bean
    public BCryptPasswordEncoder passwordEncoder(){
        return new BCryptPasswordEncoder();
    }

    //指定认证对象的来源
    public void configure(AuthenticationManagerBuilder auth) throws Exception {
        auth.userDetailsService(userService).passwordEncoder(passwordEncoder());
    }
    //SpringSecurity配置信息
    public void configure(HttpSecurity http) throws Exception {
        http.csrf()
                .disable()
                .authorizeRequests()
                .antMatchers("/user/query").hasAnyRole("ADMIN")
                .anyRequest()
                .authenticated()
                .and()
                .addFilter(new TokenLoginFilter(super.authenticationManager(), prop))
                .addFilter(new TokenVerifyFilter(super.authenticationManager(), prop))
                .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS);
    }
}
```

[**启动服务测试**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

[启动服务](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

通过Postman来访问测试

根据token信息我们访问其他资源

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

#### 2.4资源系统创建

**说明**

资源服务可以有很多个，这里只拿产品服务为例，记住，资源服务中只能通过公钥验证认证。不能签发token！创建产品服务并导入jar包根据实际业务导包即可，咱们就暂时和认证服务一样了。最新面试题整理好了，点击[Java面试库](https://mp.weixin.qq.com/s/5xt0i7Bwj4-Io-lYDkySug)小程序在线刷题。

接下来我们再创建一个资源服务

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

**导入相关的依赖**

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    <dependency>
        <artifactId>security-jwt-common</artifactId>
        <groupId>com.dpb</groupId>
        <version>1.0-SNAPSHOT</version>
    </dependency>
    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
        <version>5.1.47</version>
    </dependency>
    <dependency>
        <groupId>org.mybatis.spring.boot</groupId>
        <artifactId>mybatis-spring-boot-starter</artifactId>
        <version>2.1.0</version>
    </dependency>
    <dependency>
        <groupId>com.alibaba</groupId>
        <artifactId>druid</artifactId>
        <version>1.1.10</version>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-configuration-processor</artifactId>
        <optional>true</optional>
    </dependency>
</dependencies>
```

**编写产品服务配置文件**

切记这里只能有公钥地址！

```yaml
server:
  port: 9002
spring:
  datasource:
    driver-class-name: com.mysql.jdbc.Driver
    url: jdbc:mysql://localhost:3306/srm
    username: root
    password: 123456
    type: com.alibaba.druid.pool.DruidDataSource
mybatis:
  type-aliases-package: com.dpb.domain
  mapper-locations: classpath:mapper/*.xml
logging:
  level:
    com.dpb: debug
rsa:
  key:
    pubKeyFile: c:\tools\auth_key\id_key_rsa.pub
```

**编写读取公钥的配置类**

```java
@Data
@ConfigurationProperties(prefix = "rsa.key")
public class RsaKeyProperties {

    private String pubKeyFile;

    private PublicKey publicKey;

    /**
     * 系统启动的时候触发
     * @throws Exception
     */
    @PostConstruct
    public void createRsaKey() throws Exception {
        publicKey = RsaUtils.getPublicKey(pubKeyFile);
    }

}
```

**编写启动类**

```java
@SpringBootApplication
@MapperScan("com.dpb.mapper")
@EnableConfigurationProperties(RsaKeyProperties.class)
public class App {

    public static void main(String[] args) {
        SpringApplication.run(App.class,args);
    }
}
```

**复制认证服务中，用户对象，角色对象和校验认证的接口**

复制认证服务中的相关内容即可

**复制认证服务中SpringSecurity配置类做修改**

```java
@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(securedEnabled=true)
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

    @Autowired
    private UserService userService;

    @Autowired
    private RsaKeyProperties prop;

    @Bean
    public BCryptPasswordEncoder passwordEncoder(){
        return new BCryptPasswordEncoder();
    }

    //指定认证对象的来源
    public void configure(AuthenticationManagerBuilder auth) throws Exception {
        auth.userDetailsService(userService).passwordEncoder(passwordEncoder());
    }
    //SpringSecurity配置信息
    public void configure(HttpSecurity http) throws Exception {
        http.csrf()
                .disable()
                .authorizeRequests()
                //.antMatchers("/user/query").hasAnyRole("USER")
                .anyRequest()
                .authenticated()
                .and()
                .addFilter(new TokenVerifyFilter(super.authenticationManager(), prop))
                // 禁用掉session
                .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS);
    }
}
```

去掉“增加自定义认证过滤器”即可！

**编写产品处理器**

```java
@RestController
@RequestMapping("/user")
public class UserController {

    @RequestMapping("/query")
    public String query(){
        return "success";
    }

    @RequestMapping("/update")
    public String update(){
        return "update";
    }
}
```

**测试**

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

作者：波波烤鸭
来源：dpb-bobokaoya-sm.blog.csdn.net/artiacle/details/103409430

— End —



**最近热文：**



\1. [Spring Boot 学习笔记，这个太全了！](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

\2. [新来的同事问我 where 1=1 是什么意思?](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247497341&idx=1&sn=2031b3c2a0fb50e59395ad7d3c828ac7&chksm=fa2a1d79cd5d946f5af3578325a7ef6bfad8001a1fdfae97d9672c6864cf285ff7fa91960bcb&scene=21#wechat_redirect)

\3. [图文详解 Spring AOP，看完必懂！](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247497647&idx=1&sn=7144116f86b8c422332c3c7cb9a54bfc&chksm=fa2a1cabcd5d95bd84faea3d14b87259622f5c33efc3d4c10271f0b741af87da82dff94a8350&scene=21#wechat_redirect)

\4. [参数校验别再写满屏的 if/else 了…](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247497051&idx=1&sn=440c26b47b6f728cb189d494b4f037f6&chksm=fa2a1e5fcd5d974944d4911bb04c94849d2137e8fc9edb5d57102a87e8ee78360969943ecd3b&scene=21#wechat_redirect)

\5. [Tomcat 有哪些组成部分？讲讲工作原理？](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247497610&idx=1&sn=24cac752182ee0f8c5790e06bd0616c8&chksm=fa2a1c8ecd5d95984d1a994784a9ff3d49791ec00571abadf13a9e6f69713188b7958f1c1b66&scene=21#wechat_redirect)

