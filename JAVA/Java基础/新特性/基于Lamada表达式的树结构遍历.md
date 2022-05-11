# [基于Lamada表达式的树结构遍历](https://www.jianshu.com/p/24f7475c3fde)

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
        rootList.forEach(beanTree -> getChild(beanTree, map));

        System.out.println(Arrays.toString(rootList.toArray()));
        beanList.addAll(rootList);
        System.out.println(Arrays.toString(beanList.toArray()));
        System.out.println(Arrays.toString(bodyList.toArray()));
    }

    /**
     * 方法描述
     * @author yihur
     * @date 2019/4/4
     * @param beanTree
     * @param map
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



----



# [使用lambda表达式快捷完成Tree结构](https://blog.csdn.net/tutian2000/article/details/117321381)

前言
以前在java中构建菜单、区划等都是使用递归或是数据库。
数据库如pg、mysql等原生不支持tree结构，递归不是很好理解，同时代码太长。所以考虑使用java1.8以后支持的lambda操作一波

PS:数据库我使用了mybatis-plus，所以查数据的写法简化了

```java
main(){
//查找所有菜单，正序排序
		List<MenuEntity> list = this.list(Wrappers.lambdaQuery(MenuEntity.class)
				                                  .eq(MenuEntity::getHide, 		BoolStateEnum.FALSE.getCode())
				                                  .orderByAsc(MenuEntity::getSort));
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

```

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

}
```



