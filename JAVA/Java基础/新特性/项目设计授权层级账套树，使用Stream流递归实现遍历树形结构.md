# [Java8新特性：使用Stream流递归实现遍历树形结构](https://blog.csdn.net/weixin_36380516/article/details/115258360)

可能平常会遇到一些需求，比如构建菜单，构建[树形结构](https://so.csdn.net/so/search?q=树形结构&spm=1001.2101.3001.7020)，数据库一般就使用父id来表示，为了降低数据库的查询压力，我们可以使用Java8中的Stream流一次性把数据查出来，然后通过流式处理，我们一起来看看，代码实现为了实现简单，就模拟查看数据库所有数据到List里面。

## 示例一：

实体类：Menu.java

```java
/**
 * Menu
 *
 * @author lcry
 */
@Data
@Builder
public class Menu {
    /**
     * id
     */
    public Integer id;
    /**
     * 名称
     */
    public String name;
    /**
     * 父id ，根节点为0
     */
    public Integer parentId;
    /**
     * 子节点信息
     */
    public List<Menu> childList;
 
 
    public Menu(Integer id, String name, Integer parentId) {
        this.id = id;
        this.name = name;
        this.parentId = parentId;
    }
 
    public Menu(Integer id, String name, Integer parentId, List<Menu> childList) {
        this.id = id;
        this.name = name;
        this.parentId = parentId;
        this.childList = childList;
    }
    
}
```

递归组装树形结构：

```java
@Test
public void testtree(){
    //模拟从数据库查询出来
    List<Menu> menus = Arrays.asList(
            new Menu(1,"根节点",0),
            new Menu(2,"子节点1",1),
            new Menu(3,"子节点1.1",2),
            new Menu(4,"子节点1.2",2),
            new Menu(5,"根节点1.3",2),
            new Menu(6,"根节点2",1),
            new Menu(7,"根节点2.1",6),
            new Menu(8,"根节点2.2",6),
            new Menu(9,"根节点2.2.1",7),
            new Menu(10,"根节点2.2.2",7),
            new Menu(11,"根节点3",1),
            new Menu(12,"根节点3.1",11)
    );
 
    //获取父节点，因为最顶级父节点唯一id是0，所以只需要写死parentid==0，找出下面的所有子节点即可
    //如果最顶级父节点不唯一且id不同，则需要在外层再套一层顶级父节点循环，遍历找出每一个下面的所有子节点，见示例二
    List<Menu> collect = menus.stream().filter(m -> m.getParentId() == 0).map(
            (m) -> {
                m.setChildList(getChildrens(m, menus));
                return m;
            }
    ).collect(Collectors.toList());
    System.out.println("-------转json输出结果-------");
    System.out.println(JSON.toJSON(collect));
}
 
/**
 * 递归查询子节点
 * @param root  根节点
 * @param all   所有节点
 * @return 根节点信息
 */
private List<Menu> getChildrens(Menu root, List<Menu> all) {
    List<Menu> children = all.stream().filter(m -> {
        return Objects.equals(m.getParentId(), root.getId());
    }).map(
            (m) -> {
                m.setChildList(getChildrens(m, all));
                return m;
            }
    ).collect(Collectors.toList());
    return children;
}	
```

格式化打印结果：

![img](E:\学习\JAVA\Java基础\新特性\Lambda 表达式.assets\f5f6782a09ff880e3fc07c99f8fe6b85.png)

## 示例二：

```java
package com.yihur.demo;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import org.junit.Before;
import org.junit.Test;

import java.util.*;

/**
 * @author yihur
 * @description 树结构遍历---已知子节点遍历子节点的所有叶子节点
 * @date 2019/4/1
 */
public class TreeTestDemo {

    private List<Map<String,Object>> bodyList;

    private List<Map<String,Object>> rootList;

    //用于存放该节点下所有节点,
    private List<Map<String,Object>> beanList;

    @Before
    public void before_new_list(){
        bodyList = new ArrayList<>();
        rootList = new ArrayList<>();
        beanList = new ArrayList<>();
    }

    /**
     * 所有节点
     * @author yihur
     * @date 2019/4/4
     * @param
     * @return java.util.List<java.util.Map<java.lang.String,java.lang.Object>>
     */
    private List<Map<String,Object>> selectAllTreeNode(){
        List<Map<String,Object>> resultReturn= new ArrayList<>();
        Map<String,Object> map = new HashMap<>();

        map.put("id","100");
        map.put("parentID","10");
        resultReturn.add(map);
        map = new HashMap<>();

        map.put("id","200");
        map.put("parentID","100");
        resultReturn.add(map);
        map = new HashMap<>();

        map.put("id","201");
        map.put("parentID","100");
        resultReturn.add(map);
        map = new HashMap<>();

        map.put("id","300");
        map.put("parentID","200");
        resultReturn.add(map);
        map = new HashMap<>();

        map.put("id","301");
        map.put("parentID","201");
        resultReturn.add(map);
        map = new HashMap<>();

        map.put("id","400");
        map.put("parentID","300");
        resultReturn.add(map);
        map = new HashMap<>();

        map.put("id","401");
        map.put("parentID","301");
        resultReturn.add(map);
        map = new HashMap<>();

        map.put("id","500");
        map.put("parentID","400");
        resultReturn.add(map);
        map = new HashMap<>();

        map.put("id","501");
        map.put("parentID","401");
        resultReturn.add(map);

        return resultReturn;
    }

    /**
     * 根节点 或 起始节点
     * @author yihur
     * @date 2019/4/4
     * @param
     * @return java.util.List<java.util.Map<java.lang.String,java.lang.Object>>
     */
    private List<Map<String,Object>> selectRootTreeNode(){
        List<Map<String,Object>> resultReturn= new ArrayList<>();
        Map<String,Object> map = new HashMap<>();

        map.put("id","100");
        map.put("parentID","10");
        resultReturn.add(map);
        map = new HashMap<>();

        map.put("id","200");
        map.put("parentID","100");
        resultReturn.add(map);

        return resultReturn;
    }


    @Test
    public void test_tree_node_by_current_node(){
        List<Map<String,Object>> rootList = selectRootTreeNode();
        bodyList = selectAllTreeNode();
        // newHashMapWithExpectedSize是guava中的方法,用于初始化一个特定大小的HashMap
        Map<String, String> map = Maps.newHashMapWithExpectedSize(bodyList.size());
        //最顶级父节点有多个，找出每一个下的所有子节点
        rootList.forEach(beanTree -> getChild(beanTree, map));

        System.out.println(Arrays.toString(rootList.toArray()));
        beanList.addAll(rootList);
        System.out.println(Arrays.toString(beanList.toArray()));
        System.out.println(Arrays.toString(bodyList.toArray()));
    }

    /**
     * 方法描述，会循环调用查找子节点的方法，将当前字节的当作父节点再次查找下下级子节点
     * @author yihur
     * @date 2019/4/4
     * @param beanTree，父节点
     * @param map，保存父节点下的所有子节点
     * @return void
     */
    private void getChild(Map<String, Object> beanTree ,Map<String, String> map) {
        List<Map<String,Object>> childList = Lists.newArrayList();
        bodyList.stream()
                .filter(c -> !map.containsKey(c.get("id").toString()))
                .filter(c -> c.get("parentID").toString().equals(beanTree.get("id").toString()))
                .forEach(c -> {
                    map.put(c.get("id").toString(), c.get("parentID").toString());
                    getChild(c, map);
                    childList.add(c);
                });
        // 所有叶子结点不加childList参数,避免叶子节点带有该参数下,前端控件依然显示加号
        if (childList.size() != 0) {
            beanTree.put("childList",childList);
            beanList.addAll(childList);
        }
    }


}
```

## 示例三：

只设置了一级子菜单

```java
public class MenuEntity {
	@ApiModelProperty(value = "ID")
	@TableId
	private Long id;

	@ApiModelProperty(value = "创建时间")
	private LocalDateTime createTime;

	@ApiModelProperty(value = "创建人ID")
	private String createUserId;

	@ApiModelProperty(value = "修改时间")
	private LocalDateTime updateTime;

	@ApiModelProperty(value = "修改人ID")
	private String updateUserId;
	@ApiModelProperty(value = "节点名")
	private String name;
	@ApiModelProperty(value = "所有上级节点id列表 为空时表示最顶层")
	private Long parentId;

	@ApiModelProperty(value = "菜单类型 0=节点 1=菜单 2=按钮")
	private int menuType;

	@ApiModelProperty(value = "图标")
	private String icon;
	@ApiModelProperty(value = "url")
	private String url;
	@ApiModelProperty(value = "hash路由")
	private String hash;

	@ApiModelProperty(value = "是否隐藏 0=不隐藏 1=隐藏")
	private int hide;
	@ApiModelProperty(value = "排序，从小到大正向排序")
	private int sort;

	@ApiModelProperty(value = "下级菜单集合")
	@TableField(exist = false)
	private List<MenuEntity> children;

main(){
//查找所有菜单，正序排序
		List<MenuEntity> list = this.list(Wrappers.lambdaQuery(MenuEntity.class)
.eq(MenuEntity::getHide,BoolStateEnum.FALSE.getCode()).orderByAsc(MenuEntity::getSort));
		//找寻下级菜单，利用.map来保证引用地址相同
		list.stream()
				.map(ele -> {
					ele.setChildren(this.fromTree(ele, list));
					return ele;
				})
				.collect(Collectors.toList());

		//过滤出最上级的菜单
		return list.stream()
				       .filter(ele -> ele.getParentId() == null)
				       .collect(Collectors.toList());
}


/**
	 * 找寻指定菜单的下级菜单
	 *
	 * @param menuEntity 当前菜单
	 * @param list       所有的菜单list
	 * @return 下级菜单
	 */
	private List<MenuEntity> fromTree(MenuEntity menuEntity, List<MenuEntity> list) {
		return list.stream()
				       .filter(ele -> menuEntity.getId().equals(ele.getParentId()))
				       .collect(Collectors.toList());
	}


}

```



# [java8新特性 非常简单的递归查询所有子节点树](https://blog.csdn.net/yangjiaaiLM/article/details/120435501)

### 一、首先看看我的菜单表结构

![img](https://img-blog.csdnimg.cn/2021092315154668.png?x-oss-process=image/watermark,type_ZHJvaWRzYW5zZmFsbGJhY2s,shadow_50,text_Q1NETiBA5p2o6ICB5p2_54ix57yW56CB,size_20,color_FFFFFF,t_70,g_se,x_16)

其中我添加了一点数据来测试

![img](https://img-blog.csdnimg.cn/20210923151656585.png?x-oss-process=image/watermark,type_ZHJvaWRzYW5zZmFsbGJhY2s,shadow_50,text_Q1NETiBA5p2o6ICB5p2_54ix57yW56CB,size_20,color_FFFFFF,t_70,g_se,x_16)

 可以看到我所有菜单的父级都是 系统管理（自己也可以添加不同的父子级关系）

## 二、 Java8递归遍历

### 1、菜单的实体类

```java
@Data
@EqualsAndHashCode(callSuper = false)
@ApiModel(value="SysMenu对象", description="")
public class SysMenu implements Serializable {

    private static final long serialVersionUID = 1L;

    @ApiModelProperty(value = "ID")
    @TableId(value = "menu_id", type = IdType.AUTO)
    private Integer menuId;

    @ApiModelProperty(value = "父ID")
    private Integer parentId;

    @ApiModelProperty(value = "名称")
    private String name;

    @ApiModelProperty(value = "路径")
    private String component;

    @ApiModelProperty(value = "路由")
    private String path;

    @ApiModelProperty(value = "等级")
    private Integer level;

    @ApiModelProperty(value = "类型   0：目录，1：菜单， 2：按钮")
    private Integer type;

    @ApiModelProperty(value = "图标")
    private String icon;

    @ApiModelProperty(value = "排序")
    private Integer sort;

    @ApiModelProperty(value = "状态   0：失效   1：启用")
    private Integer status;

    @ApiModelProperty(value = "shiro权限标识")
    private String permit;

    @ApiModelProperty(value = "父名称")
    @TableField(exist = false)
    private String pname;

}
```

### 2、前端需要的树形格式  这里用VO（这里我前端是用的elment-ui的树）

```java
/**
 * 菜单的VO
 */
@Data
public class MenuVO {
    private String path;
    private String component;
    private boolean alwaysShow;
    private String name;
    private MetaVO meta;
    private List<MenuVO> children;
}
```

### 3、service实现 重点来了：

```java
    @Override
    public List<MenuVO> getListMenuVO(List<Integer> roleId) {
        //查询出所有菜单，这里过滤了一个状态条件（mybatis-puls的写法，不了解的同学可以去看下mybatis-puls）
        QueryWrapper<SysMenu> sysMenuQueryWrapper = new QueryWrapper<>();
        sysMenuQueryWrapper.eq("status",1);
        sysMenuQueryWrapper.orderByAsc("sort");
        List<SysMenu> sysMenus = list(sysMenuQueryWrapper);
        //第一个参数必须是当前最高目录的parentId的值，这里写0也就是一级目录的parentId的值
        return recursionForMenu(0,sysMenus);
    }
    /**
     * 左侧菜单通过递归算法实现树
     * @param parentId 父Id
     * @param menuList 当前所有菜单
     * @return
     */
    private List<MenuVO> recursionForMenu(int parentId,List<SysMenu> menuList){
        List<MenuVO> list = new ArrayList<>();
        /**
         * Optional.ofNullable(menuList).orElse(new ArrayList<>())  如果menuList是空的则返回一个new ArrayList<>()
         *  .stream() 返回List中的流
         *  .filter(menu -> menu.getParentId().equals(parentId)) 筛选List，返回只有条件成立的元素（当前元素的parentId必须等于父id）
         *  .forEach 遍历这个list
         */
        Optional.ofNullable(menuList).orElse(new ArrayList<>())
                .stream()
                .filter(menu -> menu.getParentId().equals(parentId))
                .forEach(menu -> {
                    MenuVO menuVO = new MenuVO();
                    menuVO.setName(menu.getName());
                    //是否是目录
                    menuVO.setAlwaysShow(menu.getLevel().equals(1)?true:false);
                    menuVO.setPath(menu.getPath());
                    menuVO.setComponent(StringUtils.isNotEmpty(menu.getComponent())?menu.getComponent():"Layout");
                    menuVO.setMeta(new MetaVO(menu.getName(),menu.getIcon(),new ArrayList<>(Arrays.asList(1))));
                    List<MenuVO> children=recursionForMenu(menu.getMenuId(),menuList);
                    menuVO.setChildren(children);
                    list.add(menuVO);
                });
        return list;
    }
```

### 4、controller控制器

```java
    @Autowired
    private SysMenuService sysMenuService;
 
    @ApiOperation(value = "获取菜单树")
    @GetMapping("/getMenuList")
    public ResponseEntity<ResponseInfo> getMenuList(HttpServletRequest request) {
        ResponseInfo ri = new ResponseInfo();
        List<MenuVO> menuVOS = sysMenuService.getListMenuVO(null);
        ri.setData(menuVOS);
        return ResponseEntity.ok().body(ri.ok());
    }
```

### 5、结果

```json
"data": [
        {
            "path": "/permission",
            "component": "Layout",
            "alwaysShow": true,
            "name": "系统管理",
            "meta": {
                "title": "系统管理",
                "icon": "el-icon-s-tools",
                "roles": [
                    1
                ]
            },
            "children": [
                {
                    "path": "organization",
                    "component": "user/organization/organization-index",
                    "alwaysShow": false,
                    "name": "企业管理",
                    "meta": {
                        "title": "企业管理",
                        "icon": "el-icon-office-building",
                        "roles": [
                            1
                        ]
                    },
                    "children": []
                },
                {
                    "path": "page",
                    "component": "permission/directive",
                    "alwaysShow": false,
                    "name": "角色管理",
                    "meta": {
                        "title": "角色管理",
                        "icon": "el-icon-s-custom",
                        "roles": [
                            1
                        ]
                    },
                    "children": []
                },
                {
                    "path": "role",
                    "component": "permission/role",
                    "alwaysShow": false,
                    "name": "部门管理",
                    "meta": {
                        "title": "部门管理",
                        "icon": "el-icon-s-home",
                        "roles": [
                            1
                        ]
                    },
                    "children": []
                },
                {
                    "path": "menu",
                    "component": "user/menu/menu-index",
                    "alwaysShow": false,
                    "name": "菜单管理",
                    "meta": {
                        "title": "菜单管理",
                        "icon": "el-icon-s-order",
                        "roles": [
                            1
                        ]
                    },
                    "children": []
                }
            ]
        }
    ]
```



# 项目中设计用户授权层级账套树

项目包含表结构：

TXSBK01账套树表

详细使用见：账套结构树查询.java/.xml

```sql
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE sqlMap  PUBLIC "-//ibatis.apache.org//DTD SQL Map 2.0//EN" "http://ibatis.apache.org/dtd/sql-map-2.dtd">
<sqlMap namespace="BK01">

<!--找到该节点下的所有等级子节点-->
    <select id="queryTree" parameterClass="java.util.List" resultClass="java.util.HashMap">
        WITH orgTree (ARCHIVE_FLAG,
        ACCT_PERIOD_NO,
        COMPANY_CODE,
        MODEL_TYPE,
        NODE_LEVEL,
        NODE_ID,
        COMPANY_CODE_CN,
        PARENT_NODE_ID,
        LAST_FLAG,
        COMB_FLAG,
        CURRENCY_CODE,
        VALID_FLAG) AS (
        SELECT
        ARCHIVE_FLAG,
        ACCT_PERIOD_NO,
        COMPANY_CODE,
        MODEL_TYPE,
        NODE_LEVEL,
        NODE_ID,
        COMPANY_CODE_CN,
        PARENT_NODE_ID,
        LAST_FLAG,
        COMB_FLAG,
        CURRENCY_CODE,
        VALID_FLAG
        FROM
        IPLATV63.TXSBK01
        WHERE
        NODE_ID IN
        <iterate conjunction="," open="(" close=")">
            #nodeList[]#
        </iterate>
        AND ACCT_PERIOD_NO = (
        SELECT
        ACCT_PERIOD_NO
        FROM
        IPLATV63.TXSBK01
        ORDER BY
        ACCT_PERIOD_NO DESC FETCH FIRST 1 ROWS ONLY)
        UNION ALL
        SELECT
        b.ARCHIVE_FLAG,
        b.ACCT_PERIOD_NO,
        b.COMPANY_CODE,
        b.MODEL_TYPE,
        b.NODE_LEVEL,
        b.NODE_ID,
        b.COMPANY_CODE_CN,
        b.PARENT_NODE_ID,
        b.LAST_FLAG,
        b.COMB_FLAG,
        b.CURRENCY_CODE,
        b.VALID_FLAG
        FROM
        orgTree a,
        IPLATV63.TXSBK01 b
        WHERE
        b.PARENT_NODE_ID = a.NODE_ID
        AND b.ACCT_PERIOD_NO = (
        SELECT
        ACCT_PERIOD_NO
        FROM
        IPLATV63.TXSBK01
        ORDER BY
        ACCT_PERIOD_NO DESC FETCH FIRST 1 ROWS ONLY))
        SELECT
        DISTINCT
        ARCHIVE_FLAG,
        ACCT_PERIOD_NO,
        COMPANY_CODE,
        MODEL_TYPE,
        NODE_LEVEL,
        NODE_ID,
        COMPANY_CODE_CN,
        PARENT_NODE_ID,
        LAST_FLAG,
        COMB_FLAG,
        CURRENCY_CODE,
        VALID_FLAG
        FROM
        orgTree
    </select>

    <!--  查出当前账户下在TXSBK02账户授权表中授权的一级账套  -->
    <select id="queryTXSBK02ByEmpCodeAndfunMod" parameterClass="java.util.HashMap" resultClass="java.util.HashMap">
        SELECT
        t1.ARCHIVE_FLAG,
        t1.ACCT_PERIOD_NO,
        t1.COMPANY_CODE,
        t1.MODEL_TYPE,
        t1.NODE_LEVEL,
        t1.NODE_ID,
        t1.COMPANY_CODE_CN,
        t1.PARENT_NODE_ID,
        t1.LAST_FLAG,
        t1.COMB_FLAG,
        t1.CURRENCY_CODE,
        t1.VALID_FLAG,
        t2.EMP_CODE,
        t2.USER_NAME,
        t2.FUN_MOD,
        t2.AU_FLAG
        FROM
        IPLATV63.TXSBK01 t1
        LEFT JOIN IPLATV63.TXSBK02 t2 ON t1.COMPANY_CODE = t2.COMPANY_INNER_CODE
        WHERE t2.EMP_CODE = #empCode# AND t2.FUN_MOD = #funMod# AND LEFT (t1.NODE_ID,3) = #itemCode#
        AND t1.ACCT_PERIOD_NO = (SELECT
            ACCT_PERIOD_NO
            FROM
            IPLATV63.TXSBK01
            ORDER BY
            ACCT_PERIOD_NO DESC FETCH FIRST 1 ROWS ONLY)
        ORDER BY t1.NODE_LEVEL ASC
    </select>

    <select id="queryIndustryClass" resultClass="java.util.HashMap">
        SELECT
            t.ITEM_CODE,
            t.ITEM_CNAME,
            t.SORT_ID,
            LISTAGG(t2.COMPANY_INNER_CODE,',') AS COMPANY_INNER_CODE,
            t2.ACCT_PERIOD_NO
        FROM
            IPLATV63.TEDCM01 t
                LEFT JOIN IPLATV63.TXSBK04 t2 ON
                t.ITEM_CODE = t2.FIELD_VALUE AND t.CODESET_CODE = t2.FIELD_TYPE
        WHERE t2.FIELD_TYPE = 'bwtmf.industryClass'
        GROUP BY t.ITEM_CODE,t.ITEM_CNAME,t.SORT_ID,t2.ACCT_PERIOD_NO
        ORDER BY
            t.SORT_ID ASC
    </select>

    <select id="queryTXSBK01" parameterClass="java.util.List" resultClass="java.util.HashMap">
        SELECT
        ARCHIVE_FLAG,
        ACCT_PERIOD_NO,
        COMPANY_CODE,
        MODEL_TYPE,
        NODE_LEVEL,
        NODE_ID,
        COMPANY_CODE_CN,
        PARENT_NODE_ID,
        LAST_FLAG,
        COMB_FLAG,
        CURRENCY_CODE,
        VALID_FLAG
        FROM
        IPLATV63.TXSBK01
        WHERE
        COMPANY_CODE IN
        <iterate conjunction="," open="(" close=")">
            #companyCodeList[]#
        </iterate>
        AND ACCT_PERIOD_NO = (select ACCT_PERIOD_NO from IPLATV63.TXSBK04 where FIELD_TYPE = 'bwtmf.industryClass' FETCH FIRST 1 ROWS ONLY)
        AND LEFT (NODE_ID,3) = '001'
        AND MODEL_TYPE = 'KJ01'
    </select>

    <!--  根据配置业务属性的账套去授权的账套树找到交集并往上递归  -->
    <select id="queryTreeByBusiness" parameterClass="java.util.HashMap" resultClass="java.util.HashMap">
        WITH orgTree (ARCHIVE_FLAG,
                      ACCT_PERIOD_NO,
                      COMPANY_CODE,
                      MODEL_TYPE,
                      NODE_LEVEL,
                      NODE_ID,
                      COMPANY_CODE_CN,
                      PARENT_NODE_ID,
                      LAST_FLAG,
                      COMB_FLAG,
                      CURRENCY_CODE,
                      VALID_FLAG) AS (
            SELECT ARCHIVE_FLAG,
                   ACCT_PERIOD_NO,
                   COMPANY_CODE,
                   MODEL_TYPE,
                   NODE_LEVEL,
                   NODE_ID,
                   COMPANY_CODE_CN,
                   PARENT_NODE_ID,
                   LAST_FLAG,
                   COMB_FLAG,
                   CURRENCY_CODE,
                   VALID_FLAG
            FROM IPLATV63.TXSBK01
            WHERE NODE_ID IN (
                SELECT NODE_ID
                FROM IPLATV63.TXSBK01
                WHERE COMPANY_CODE IN (
                    SELECT COMPANY_INNER_CODE
                    FROM IPLATV63.TXSBK04
                    WHERE FIELD_TYPE = 'bwtmf.bizType'
                      AND FIELD_VALUE = #businessType#)
                  AND LEFT (NODE_ID,3) = #itemCode#
            AND ACCT_PERIOD_NO = (
            SELECT
            ACCT_PERIOD_NO
            FROM
            IPLATV63.TXSBK01
            ORDER BY
            ACCT_PERIOD_NO DESC FETCH FIRST 1 ROWS ONLY))
            AND ACCT_PERIOD_NO = (
        SELECT
            ACCT_PERIOD_NO
        FROM
            IPLATV63.TXSBK01
        ORDER BY
            ACCT_PERIOD_NO DESC FETCH FIRST 1 ROWS ONLY)
        UNION ALL
        SELECT b.ARCHIVE_FLAG,
               b.ACCT_PERIOD_NO,
               b.COMPANY_CODE,
               b.MODEL_TYPE,
               b.NODE_LEVEL,
               b.NODE_ID,
               b.COMPANY_CODE_CN,
               b.PARENT_NODE_ID,
               b.LAST_FLAG,
               b.COMB_FLAG,
               b.CURRENCY_CODE,
               b.VALID_FLAG
        FROM orgTree a,
             IPLATV63.TXSBK01 b
        WHERE b.NODE_ID = a.PARENT_NODE_ID
        AND b.ACCT_PERIOD_NO = (
            SELECT ACCT_PERIOD_NO
            FROM IPLATV63.TXSBK01
            ORDER BY ACCT_PERIOD_NO DESC FETCH FIRST 1 ROWS ONLY))
        ,
        temp (ARCHIVE_FLAG,
                ACCT_PERIOD_NO,
                COMPANY_CODE,
                MODEL_TYPE,
                NODE_LEVEL,
                NODE_ID,
                COMPANY_CODE_CN,
                PARENT_NODE_ID,
                LAST_FLAG,
                COMB_FLAG,
                CURRENCY_CODE,
                VALID_FLAG) AS (
        SELECT
            ARCHIVE_FLAG,
            ACCT_PERIOD_NO,
            COMPANY_CODE,
            MODEL_TYPE,
            NODE_LEVEL,
            NODE_ID,
            COMPANY_CODE_CN,
            PARENT_NODE_ID,
            LAST_FLAG,
            COMB_FLAG,
            CURRENCY_CODE,
            VALID_FLAG
        FROM
            orgTree
        WHERE
            NODE_ID = #nodeId#
        UNION ALL
        SELECT
            b.ARCHIVE_FLAG,
            b.ACCT_PERIOD_NO,
            b.COMPANY_CODE,
            b.MODEL_TYPE,
            b.NODE_LEVEL,
            b.NODE_ID,
            b.COMPANY_CODE_CN,
            b.PARENT_NODE_ID,
            b.LAST_FLAG,
            b.COMB_FLAG,
            b.CURRENCY_CODE,
            b.VALID_FLAG
        FROM
            temp a,
            orgTree b
        WHERE
            b.PARENT_NODE_ID = a.NODE_ID
        )
        SELECT DISTINCT ARCHIVE_FLAG,
                        ACCT_PERIOD_NO,
                        COMPANY_CODE,
                        MODEL_TYPE,
                        NODE_LEVEL,
                        NODE_ID,
                        COMPANY_CODE_CN,
                        PARENT_NODE_ID,
                        LAST_FLAG,
                        COMB_FLAG,
                        CURRENCY_CODE,
                        VALID_FLAG
        FROM temp
    </select>

    <select id="queryByNodeId" parameterClass="java.util.HashMap" resultClass="java.util.HashMap">
        SELECT
        ARCHIVE_FLAG,
        ACCT_PERIOD_NO,
        COMPANY_CODE,
        MODEL_TYPE,
        NODE_LEVEL,
        NODE_ID,
        COMPANY_CODE_CN,
        PARENT_NODE_ID,
        LAST_FLAG,
        COMB_FLAG,
        CURRENCY_CODE,
        VALID_FLAG
        FROM
        IPLATV63.TXSBK01
        WHERE
        PARENT_NODE_ID = #nodeId#
        AND ACCT_PERIOD_NO = (SELECT
        ACCT_PERIOD_NO
        FROM
        IPLATV63.TXSBK01
        ORDER BY
        ACCT_PERIOD_NO DESC FETCH FIRST 1 ROWS ONLY)
        <isNotEmpty prepend=" AND " property="companyCodeCn">
            COMPANY_CODE_CN LIKE '%'||#companyCodeCn#||'%'
        </isNotEmpty>
    </select>

</sqlMap>
```



