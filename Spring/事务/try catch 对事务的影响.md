# try catch 对事务的影响

spring 的默认事务机制，当出现unchecked异常时候回滚，checked异常的时候不会回滚；

异常中unchecked异常包括error和runtime异常，需要try catch或向上抛出的异常为checked异常比如IOException，也就是说程序抛出runtime异常的时候才会进行回滚，其他异常不回滚，可以配置设置所有异常回滚： 

@Transactional(rollbackFor = { Exception.class }) 

当有try catch后捕获了异常，事务不会回滚，如果不得不在service层写try catch 需要catch后 throw new RuntimeException 让事务回滚； 

Spring的AOP即声明式事务管理默认是针对unchecked exception回滚。也就是默认对R untimeException()异常或是其子类进行事务回滚；checked异常,即Exception可try{}捕获的不会回滚，如果使用try-catch捕获抛出的unchecked异常后没有在catch块中采用页面硬编码的方式使用spring api对事务做显式的回滚，则事务不会回滚， “将异常捕获,并且在catch块中不对事务做显式提交=生吞掉异常” ，要想捕获非运行时异常则需要如下配置



# [spring事务管理中，用try-catch处理了异常，事务也会回滚？][https://blog.csdn.net/C_AJing/article/details/106054265]

我们知道在平时的开发中，如果在事务方法中开发人员自己用try-catch处理了异常，那么spring aop就捕获不到异常信息，从而会导致spring不能对事务方法正确的进行管理，不能及时回滚错误信息。

下面用代码演示一下：

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int doSaveUser() throws Exception {
        int result = 0;
        UserEntity u = new UserEntity();
        u.setUserSex("男");
        u.setUserName("AAA");
        try {
            result = userMapper.insertUser(u);
            int i = 1 / 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

控制台报错：![在这里插入图片描述](try catch 对事务的影响.assets/20200511145546432.png#pic_center)

数据库：![在这里插入图片描述](try catch 对事务的影响.assets/20200511145622666.png#pic_center)



可以看到程序虽然报错了，但是事务并没有回滚，这就是由于我们自己处理了异常信息。

可是，只要是我们自己处理了异常，事务就一定不会回滚吗？答案是不一定的，下面用两段代码对比一下：

代码一：

    public class User2ServiceImpl implements User2Service {
        @Autowired
        private UserService userService;
        @Autowired
        private UserMapper userMapper;
        
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int doSaveUser() throws Exception {
        int result = 0;
        UserEntity u = new UserEntity();
        u.setUserSex("男");
        u.setUserName("小A");
        userMapper.insertUser(u);
        try {
            u.setUserName("小B");
            result = userService.insertUser(u); //此时调用的方法没有加事务
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }
    }


    @Service
    public class UserServiceImpl implements UserService {
    @Autowired
    private UserMapper userMapper;
    
    @Override
    public int insertUser(UserEntity user) throws Exception {
        int i = 1 / 0;
        return userMapper.insertUser(user);
    }
    }


异常信息：![在这里插入图片描述](try catch 对事务的影响.assets/20200511150703518.png#pic_center)

数据库：![在这里插入图片描述](try catch 对事务的影响.assets/20200511150738370.png#pic_center)



可以看到由于我们自己处理了保存小B时抛出的异常，事务方法没有受到影响，依然正常的保存了小A，并没有回滚事务。

代码二：



    @Service
    public class User2ServiceImpl implements User2Service {
        @Autowired
        private UserService userService;
        @Autowired
        private UserMapper userMapper;
        
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int doSaveUser() throws Exception {
        int result = 0;
        UserEntity u = new UserEntity();
        u.setUserSex("男");
        u.setUserName("小C");
        userMapper.insertUser(u);
        try {
            u.setUserName("小D");
            result = userService.insertUser(u); //此时调用的方法加上事务
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }
    }
    @Service
    public class UserServiceImpl implements UserService {
    @Autowired
    private UserMapper userMapper;
    
    @Override
    @Transactional(rollbackFor = Exception.class, propagation = Propagation.REQUIRED)
    public int insertUser(UserEntity user) throws Exception {
        int i = 1 / 0;
        return userMapper.insertUser(user);
    }}

异常信息：![在这里插入图片描述](try catch 对事务的影响.assets/20200511152435353.png#pic_center)

此时数据库里面一条记录也没有，也就是是说doSaveUser()方法也进行了事务回滚，我们已经用try-catch处理了异常了，为什么还会事务回滚呢？

我们此时把insertUser方法稍微修改一下：

```
   @Override
   @Transactional(rollbackFor = Exception.class, propagation = Propagation.REQUIRES_NEW)
    public int insertUser(UserEntity user) throws Exception {
        int i = 1 / 0;
        return userMapper.insertUser(user);
    }

```

此时数据库多了一条记录：

![在这里插入图片描述](try catch 对事务的影响.assets/20200511161126567.png#pic_center)

这里，我把spring事务传播机制从REQUIRED改成了REQUIRES_NEW，doSaveUser()方法就没有进行事务回滚了，到这里你应该能猜到了，spring事务传播机制默认是REQUIRED，也就是说支持当前事务，如果当前没有事务，则新建事务，如果当前存在事务，则加入当前事务，合并成一个事务，当insertUser方法有事务且事务传播机制为REQUIRED时，会和doSaveUser()方法的事务合并成一个事务，此时insertUser方法发生异常，spring捕获异常后，事务将会被设置全局rollback，而最外层的事务方法执行commit操作，这时由于事务状态为rollback，spring认为不应该commit提交该事务，就会回滚该事务，这就是为什么doSaveUser()方法的事务也被回滚了。

下面我们再看一下spring的事务传播机制：

1.REQUIRED (默认)：支持当前事务，如果当前没有事务，则新建事务，如果当前存在事务，则加入当前事务，合并成一个事务，如果一个方法发生异常回滚，则整个事务回滚。

2.REQUIRES_NEW：新建事务，如果当前存在事务，则把当前事务挂起，这个方法会独立提交事务，不受调用者的事务影响，父级异常，它也是正常提交，但如果是此方法发生异常未被捕获处理，且异常满足父级事务方法回滚规则，则父级方法事务会被回滚。

3.NESTED：如果当前存在事务，它将会成为父级事务的一个子事务，方法结束后并没有提交，只有等父事务结束才提交，如果当前没有事务，则新建事务（此时，类似于REQUIRED ），如果它异常，它本身进行事务回滚，父级可以捕获它的异常而不进行回滚，正常提交，但如果父级异常，它必然回滚。

4.SUPPORTS：如果当前存在事务，则加入事务，如果当前不存在事务，则以非事务方式运行。

5.NOT_SUPPORTED：以非事务方式运行，如果当前存在事务，则把当前事务挂起。

6.MANDATORY：如果当前存在事务，则运行在当前事务中，如果当前无事务，则抛出异常，即父级方法（调用此方法的方法）必须有事务。

7.NEVER：以非事务方式运行，如果当前存在事务，则抛出异常，即父级方法必须无事务。



---



# [Java异常类][https://blog.csdn.net/michaelgo/article/details/82790253]

一、异常实现及分类
1.先看下异常类的结构图

![img](try catch 对事务的影响.assets/70.png)

上图可以简单展示一下异常类实现结构图，当然上图不是所有的异常，用户自己也可以自定义异常实现。上图已经足够帮我们解释和理解异常实现了：

1.所有的异常都是从Throwable继承而来的，是所有异常的共同祖先。

2.Throwable有两个子类，Error和Exception。其中Error是错误，对于所有的编译时期的错误以及系统错误都是通过Error抛出的。这些错误表示故障发生于虚拟机自身、或者发生在虚拟机试图执行应用时，如Java虚拟机运行错误（Virtual MachineError）、类定义错误（NoClassDefFoundError）等。这些错误是不可查的，因为它们在应用程序的控制和处理能力之 外，而且绝大多数是程序运行时不允许出现的状况。对于设计合理的应用程序来说，即使确实发生了错误，本质上也不应该试图去处理它所引起的异常状况。在 Java中，错误通过Error的子类描述。

3.Exception，是另外一个非常重要的异常子类。它规定的异常是程序本身可以处理的异常。异常和错误的区别是，异常是可以被处理的，而错误是没法处理的。 

4.Checked Exception

可检查的异常，这是编码时非常常用的，所有checked exception都是需要在代码中处理的。它们的发生是可以预测的，正常的一种情况，可以合理的处理。比如IOException，或者一些自定义的异常。除了RuntimeException及其子类以外，都是checked exception。

5.Unchecked Exception

RuntimeException及其子类都是unchecked exception。比如NPE空指针异常，除数为0的算数异常ArithmeticException等等，这种异常是运行时发生，无法预先捕捉处理的。Error也是unchecked exception，也是无法预先处理的。

