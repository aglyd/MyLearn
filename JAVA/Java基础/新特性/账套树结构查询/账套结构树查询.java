package com.baosight.bwtmf.bk.service;

import com.baosight.iplat4j.core.ei.EiConstant;
import com.baosight.iplat4j.core.ei.EiInfo;
import com.baosight.iplat4j.core.log.Logger;
import com.baosight.iplat4j.core.log.LoggerFactory;
import com.baosight.iplat4j.core.service.impl.ServiceBase;
import org.apache.commons.lang3.StringUtils;

import java.util.*;
import java.util.stream.Collectors;

public class ServiceBK01 extends ServiceBase {

    Logger log = LoggerFactory.getLogger(ServiceBK01.class);

    //管理树
    public static final String MANAGE_TREE = "001";

    //资产树
    public static final String ASSET_TREE = "002";

    //一基五元树
    private static final String ONE_BASE_FIVE_YUAN_TREE = "999";

    //当前节点授权
    private static final String CURRENT_NODE = "0";

    //下一级节点授权
    private static final String NEXT_LEVEL_NODE = "1";

    //所有节点授权
    private static final String ALL_NODES = "2";

    //定制接口返回当前节点以及所有下级节点全部List数据
    private static final String ALL_DATA = "1";

    public EiInfo query(EiInfo eiInfo) {
        EiInfo outInfo = new EiInfo();
        Map<String,String> params = (Map<String, String>) eiInfo.get("params");
        String empCode = params.get("empCode");
        String funMod = params.get("funMod");
        String itemCode = params.get("itemCode");
        String businessType = params.get("businessType");

        Map<String, String> map = new HashMap<>();
        map.put("empCode", empCode);
        map.put("funMod", funMod);
        map.put("itemCode", itemCode);
        //最终返回的树
        List<Map<String, Object>> resultList = new ArrayList<>();
        //一基五元树
        try {
            if (ONE_BASE_FIVE_YUAN_TREE.equals(itemCode)) {
                resultList = queryIndustryClass(map);
            } else {
                //如果传了业务属性，根据配置业务属性的账套去授权的账套树找到交集并往上递归
                if (StringUtils.isNotBlank(businessType) && funMod.equals(businessType) && !ONE_BASE_FIVE_YUAN_TREE.equals(itemCode)) {
                    Map<String, String> businessTreeParams = new HashMap<>();
                    businessTreeParams.put("businessType", businessType);
                    businessTreeParams.put("itemCode", itemCode);
                    List<Map<String,String>> txsbk02List = dao.query("BK01.queryTXSBK02ByEmpCodeAndfunMod", map);
                    for (Map<String, String> t : txsbk02List) {
                        String nodeId = t.get("NODE_ID");
                        businessTreeParams.put("nodeId", nodeId);
                        List<Map<String,Object>> businessList = dao.query("BK01.queryTreeByBusiness", businessTreeParams);
                        List<Map<String, Object>> recursionList = recursion(businessList, nodeId, t.get("AU_FLAG"));
                        resultList.addAll(recursionList);
                    }
                //没有传业务属性，返回授权的账套节点
                } else {
                    resultList = dao.query("BK01.queryTXSBK02ByEmpCodeAndfunMod", map);
                }
            }
            outInfo.set("result", resultList);
            outInfo.setStatus(EiConstant.STATUS_SUCCESS);
            outInfo.setMsg("查询成功");
        } catch (Exception e) {
            outInfo.setStatus(EiConstant.STATUS_FAILURE);
            outInfo.setMsg("查询失败：" + e.getMessage());
        }
        return outInfo;
    }

    /**
     * 根据nodeId查询下一级节点
     * @param eiInfo
     * @return
     */
    public EiInfo query02(EiInfo eiInfo) {
        EiInfo outInfo = new EiInfo();
        Map<String, String> params = (Map<String, String>) eiInfo.get("params");
        String nodeId = params.get("nodeId");
        String companyCodeCn = params.get("companyCodeCn");
        Map<String, String> map = new HashMap<>();
        map.put("nodeId", nodeId);
        map.put("companyCodeCn", companyCodeCn);
        List<Map<String,Object>> resultList = dao.query("BK01.queryByNodeId", map);
        outInfo.set("result", resultList);
        return outInfo;
    }

    public List<Map<String, Object>> queryTree(Map<String,String> params,List<Map<String, Object>> resultList,String dataType) {
        List<Map<String,String>> txsbk02List = dao.query("BK01.queryTXSBK02ByEmpCodeAndfunMod", params);
        //返回当前节点以及所有下级节点全部List数据
        if (ALL_DATA.equals(dataType)) {
            List<String> nodeList = new ArrayList<>();
            for (Map<String, String> t : txsbk02List) {
                String nodeId = t.get("NODE_ID");
                nodeList.add(nodeId);
            }
            resultList = dao.query("BK01.queryTree", nodeList);     //找到该一级节点下所有等级子节点
        //返回授权的账套树
        } else {
            for (Map<String, String> t : txsbk02List) {
                List<String> nodeList = new ArrayList<>();
                String nodeId = t.get("NODE_ID");
                nodeList.add(nodeId);
                List<Map<String, Object>> companyTree = dao.query("BK01.queryTree", nodeList);
                List<Map<String, Object>> collect = recursion(companyTree, nodeId, t.get("AU_FLAG"));
                resultList.addAll(collect);
            }
        }
        return resultList;
    }

    /**
     * 
     * @param companyTree
     * @param nodeId    
     * @param auFlag
     * @return
     */
    public List<Map<String, Object>> recursion(List<Map<String, Object>> companyTree, String nodeId, String auFlag) {
        List<Map<String, Object>> collect = companyTree.stream()
                .filter(s -> nodeId.equals(s.get("NODE_ID")))   //当前节点为一级授权账套，找到二级子节点
                .peek(s -> s.put("children", getChildren(s, companyTree)))
                .collect(Collectors.toList());
        if (CURRENT_NODE.equals(auFlag)) {
            collect.get(0).put("children", null);
        } else if (NEXT_LEVEL_NODE.equals(auFlag)) {
            commonCodeExtraction(collect);
        }
        return collect;
    }

    //组装一基五元树
    public List<Map<String,Object>> queryIndustryClass(Map<String,String> params) {
        List<Map<String, Object>> resultIndustryList = new ArrayList<>();
        params.put("originalItemCode", params.get("itemCode"));
        params.put("itemCode", MANAGE_TREE);
        List<Map<String,String>> txsbk02List = dao.query("BK01.queryTXSBK02ByEmpCodeAndfunMod", params);
        boolean flag = false;
        String auFlag = "";
        for (Map<String, String> t : txsbk02List) {
            //根据当前登录人判断是否拥有授权的管理树的最高节点并且授权等级不为0的 (只为1或者2)
            if (MANAGE_TREE.equals(t.get("NODE_ID")) && StringUtils.isBlank(t.get("PARENT_NODE_ID")) && !CURRENT_NODE.equals(t.get("AU_FLAG"))) {
                flag = true;
                auFlag = t.get("AU_FLAG");
            }
        }
        if (flag) {
            List<Map<String, String>> industryList = dao.query("BK01.queryIndustryClass", null);
            for (Map<String, String> map : industryList) {
                List<String> companyCodeList = new ArrayList<>();
                String companyInnerCode = map.get("COMPANY_INNER_CODE");
                if (companyInnerCode.indexOf(",") != -1) {
                    companyCodeList = Arrays.asList(companyInnerCode.split(","));
                } else {
                    companyCodeList.add(map.get("COMPANY_INNER_CODE"));
                }
                List<Map<String, Object>> txsbk01 = dao.query("BK01.queryTXSBK01", companyCodeList);
                List<Map<String, Object>> resultList = new ArrayList<>();
                LinkedHashMap<String,Object> industryMap = new LinkedHashMap();
                industryMap.put("COMPANY_CODE", map.get("ITEM_CODE"));
                industryMap.put("COMPANY_CODE_CN", map.get("ITEM_CNAME"));
                for (Map<String, Object> s : txsbk01) {
                    s.put("AU_FLAG", auFlag);
                    resultList.add(s);
                }
                industryMap.put("children", resultList);
                resultIndustryList.add(industryMap);
            }
        }
        return resultIndustryList;
    }

    public List<Map<String,Object>> queryIndustryClassAll(Map<String,String> params) {
        List<Map<String, Object>> resultIndustryList = new ArrayList<>();
        params.put("originalItemCode", params.get("itemCode"));
        params.put("itemCode", MANAGE_TREE);
        List<Map<String,String>> txsbk02List = dao.query("BK01.queryTXSBK02ByEmpCodeAndfunMod", params);
        boolean flag = false;
        String auFlag = "";
        for (Map<String, String> t : txsbk02List) {
            //根据当前登录人判断是否拥有授权的管理树的最高节点并且授权等级不为0的 (只为1或者2)
            if (MANAGE_TREE.equals(t.get("NODE_ID")) && StringUtils.isBlank(t.get("PARENT_NODE_ID")) && !CURRENT_NODE.equals(t.get("AU_FLAG"))) {
                flag = true;
                auFlag = t.get("AU_FLAG");
            }
        }
        if (flag) {
            List<Map<String, String>> industryList = dao.query("BK01.queryIndustryClass", null);
            for (Map<String, String> map : industryList) {
                List<String> companyCodeList = new ArrayList<>();
                String companyInnerCode = map.get("COMPANY_INNER_CODE");
                if (companyInnerCode.indexOf(",") != -1) {
                    companyCodeList = Arrays.asList(companyInnerCode.split(","));
                } else {
                    companyCodeList.add(map.get("COMPANY_INNER_CODE"));
                }
                List<Map<String, Object>> txsbk01 = dao.query("BK01.queryTXSBK01", companyCodeList);
                List<Map<String, Object>> resultList = new ArrayList<>();
                LinkedHashMap<String,Object> industryMap = new LinkedHashMap();
                industryMap.put("COMPANY_CODE", map.get("ITEM_CODE"));
                industryMap.put("COMPANY_CODE_CN", map.get("ITEM_CNAME"));
                for (Map<String, Object> txsbk01Map : txsbk01) {
                    List<String> nodeIdList = new ArrayList<>();
                    nodeIdList.add(txsbk01Map.get("NODE_ID").toString());
                    List<Map<String, Object>> companyTree = dao.query("BK01.queryTree", nodeIdList);
                    List<Map<String, Object>> collect = recursion(companyTree, txsbk01Map.get("NODE_ID").toString(), auFlag);
                    resultList.addAll(collect);
                }
                industryMap.put("children", resultList);
                resultIndustryList.add(industryMap);
            }
        }
        return resultIndustryList;
    }

    public void commonCodeExtraction(List<Map<String, Object>> collect) {
        collect.forEach(c -> {
            List<Map<String, Object>> children = (List<Map<String, Object>>) c.get("children");
            children.forEach(b -> {
                b.put("children", null);
            });
        });
    }

    public List<Map<String, Object>> getChildren(Map<String, Object> maps, List<Map<String, Object>> allList) {
        List<Map<String, Object>> childList = allList
                .stream()
                .filter(s -> maps.get("NODE_ID").equals(s.get("PARENT_NODE_ID")))   //当前节点为二级子授权账套，找出所有子节点
                .peek(s -> s.put("children", getChildren(s, allList)))      //递归调用
                .collect(Collectors.toList());
        return childList;
    }

    /**
     * 查询用户账套数据
     * S_BK_01
     * @param eiInfo
     * @return
     */
    public EiInfo queryAll(EiInfo eiInfo) {
        EiInfo outInfo = new EiInfo();
        Map<String,String> params = (Map<String, String>) eiInfo.get("params");
        String empCode = params.get("empCode");
        String funMod = params.get("funMod");
        String itemCode = params.get("itemCode");
        String businessType = params.get("businessType");
        String dataType = params.get("dataType");

        Map<String, String> map = new HashMap<>();
        map.put("empCode", empCode);
        map.put("funMod", funMod);
        map.put("itemCode", itemCode);
        //最终返回的树
        List<Map<String, Object>> resultList = new ArrayList<>();
        //一基五元树
        try {
            if (ONE_BASE_FIVE_YUAN_TREE.equals(itemCode)) {
                resultList = queryIndustryClassAll(map);
            } else {
                //如果传了业务属性，根据配置业务属性的账套去授权的账套树找到交集并往上递归
                if (StringUtils.isNotBlank(businessType) && funMod.equals(businessType) && !ONE_BASE_FIVE_YUAN_TREE.equals(itemCode)) {
                    Map<String, String> businessTreeParams = new HashMap<>();
                    businessTreeParams.put("businessType", businessType);
                    businessTreeParams.put("itemCode", itemCode);
                    //找出账户下授权的一级账套
                    List<Map<String,String>> txsbk02List = dao.query("BK01.queryTXSBK02ByEmpCodeAndfunMod", map);
                    for (Map<String, String> t : txsbk02List) {
                        String nodeId = t.get("NODE_ID");
                        businessTreeParams.put("nodeId", nodeId);
                        //根据配置业务属性的账套去找该授权账套的所有子帐套及自己（根据当前节点账套找到所有等级子节点）找到交集并往上递归
                        // ==业务授权账套和账户授权账套的交集
                        List<Map<String,Object>> businessList = dao.query("BK01.queryTreeByBusiness", businessTreeParams);
                        List<Map<String, Object>> recursionList = recursion(businessList, nodeId, t.get("AU_FLAG"));
                        resultList.addAll(recursionList);
                    }
                    //没有传业务属性，返回授权的账套数据
                } else {
                    resultList = queryTree(map, resultList, dataType);
                }
            }
            outInfo.set("result", resultList);
            outInfo.setStatus(EiConstant.STATUS_SUCCESS);
            outInfo.setMsg("查询成功");
        } catch (Exception e) {
            outInfo.setStatus(EiConstant.STATUS_FAILURE);
            outInfo.setMsg("查询失败：" + e.getMessage());
        }
        return outInfo;
    }

    /**
     * 根据当前用户查询授权账套节点
     * S_BK_11
     * @param eiInfo
     * @return
     */
    public EiInfo queryCompanyList(EiInfo eiInfo) {
        EiInfo outInfo = new EiInfo();
        try {
            Map<String,String> params = (Map<String, String>) eiInfo.get("params");
            List<Map<String, Object>> resultList = dao.query("BK01.queryTXSBK02ByEmpCodeAndfunMod", params);
            outInfo.set("result", resultList);
            outInfo.setStatus(EiConstant.STATUS_SUCCESS);
            outInfo.setMsg("查询成功");
        } catch (Exception e) {
            outInfo.setStatus(EiConstant.STATUS_FAILURE);
            outInfo.setMsg("查询失败：" + e.getMessage());
        }
        return outInfo;
    }
	
	  /**
     * 优化账套树查询
     * 优化思路  去掉递归sql查询
     *  SQL 查询出所有数据
     * 在程序中对数据进行整理
     * 过滤出一级数据
     * 遍历一级数据
     * 通过一级数据 递归 过滤二级…等子级数据
     * @return
     */
    public EiInfo optimizeQueryTree(EiInfo eiInfo) {
        Map<String, String> params = (Map<String, String>) eiInfo.get("params");
        String itemCode = params.get("itemCode");
        Map<String, Object> map = new HashMap<>();
        if (ServiceBK01.MANAGE_TREE.equals(itemCode)) {
            map.put("nodeId", Arrays.asList(ServiceBK01.MANAGE_TREE));
        } else if (ServiceBK01.ASSET_TREE.equals(itemCode)) {
            map.put("nodeId", Arrays.asList(ServiceBK01.ASSET_TREE, ServiceBK01.ASSET_TREE_003, ServiceBK01.ASSET_TREE_004));
        }
        //首先查到管理树或者资产树的所有最新账期的数据
        List<Map<String,Object>> listAll = dao.queryAll("BK01.queryAll", map);

        //再查到授权的根节点
        List<Map<String,Object>> bk02List = dao.query("BK01.queryBK02", params);

        //获取一级目录
        List<Map<String, Object>> resultList = new ArrayList<>();
        for (Map<String, Object> bk02 : bk02List) {
            List<Map<String, Object>> rootNode = listAll.stream()
                    .filter(dict -> bk02.get("COMPANY_INNER_CODE").equals(dict.get("COMPANY_CODE")) && bk02.get("DATA_CALIBER").equals(dict.get("NODE_ID")))
                    .collect(Collectors.toList());
            rootNode.forEach(a -> {
                List<Map<String, Object>> collect = listAll.stream()
                        .filter(s -> s.get("NODE_ID").equals(a.get("NODE_ID")))
                        .peek(s -> s.put("children", getChildren(s, listAll)))
                        .collect(Collectors.toList());
                resultList.addAll(collect);
            });
        }
        EiInfo outInfo = new EiInfo();
        outInfo.set("result", resultList);
        outInfo.setStatus(EiConstant.STATUS_SUCCESS);
        return outInfo;
    }

}
