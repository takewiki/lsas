----版本更新说明
----V2:
---- 解决金蝶版本兼容性问题，使用首次登录日期取代用户创建日期
----V3：
-----解决用户列表偏少的问题
----最新版本
----V4版本要求
----4.1.去掉“HR用户”组里面的用户，
------保留HR_fiona.wu，HR_ada.liu，HR_honghui.xue，admin，HR_mary.wang
----4.2导出的数据，去掉用户组，如“Supplier Approver”等
----修复功能点
-----修复上述2个需求 
-----去年用户启用日期，用户最终登录日期中的NULL，替换为''
----V5 BUG修复
----针对启用日期进行完善

set nocount on

select * from 
(
  select u.fname as 用户名, case when e.fnumber is null then '' else e.fnumber end  as 员工代码,
  case when e.fname  is null then '' else e.fname end as 员工姓名,
  case when r.FSubSys is null then '' else r.FSubSys end   as 模块,
  case when r.FTypeName is null then '' else r.FTypeName end as 功能,
  case  r.FItemName when '转交易供应商' then '审核' when  null then '' else r.FItemName end   as 职责,
  case FForbidden when 0 then '正常' else '禁用' end   as 状态,
  case when FirstLoginDate is null then  '' else convert(varchar(10),FirstLoginDate,120) end  用户启用日期 ,
  case when last_log_date is null then '' else convert(varchar(10),last_log_date,120)  end 用户最终登录日期
  
  
  from t_user  u
  left  join   ---解决用户创建后没有登录问题
  (select FUserID,min(fdate) as FirstLoginDate,MAX(FDate) as last_log_date from t_Log  
    group by FUserID) data1
  on u.FUserID=data1.FUserID
  left join t_Emp e  --- 解决用户没有关联职员问题
  on  u.FEmpID=e.FItemID
  left join    ----解决用户没有进行权限授权问题
  (select distinct 
    w2.FSubSys as FSubSys,
    --- w.FGroupid,
    --- t3.FObjecttype,
    --- t3.FObjectID,
    ---- t4.FIndex,
    t3.FTypeName,
    t4.FName as FItemName,
    --- t4.FDescription as FDescription,
    t3.FUserName,t3.FUserID
    from ( 
      select
      t1.FObjectType,
      t1.FObjectID,
      t1.FAccessMask,
      t1.FName as FTypeName,
      t2.FUserID,t2.FName as FUserName
      from (
        select a.*,o.FName as FName 
        from t_AccessControl a,t_ObjectType o 
        where a.fObjectType=o.FObjectType and a.FObjectID=o.FObjectID) 
      t1, --系统对象权限表
      (
        select FUserID,FName ,FUserTypeID
        from t_user  
        where fforbidden=0 
        AND (FUserID>16394 or (FUserID>9 and fuserid <16384 )) ) 
      t2 --所有用户列表
      where t1.FUserID=t2.FUserID 
      and (t2.FUserTypeID=10001 or (t2.FUserTypeID=10002
      and t2.FName in 
      ('HR_fiona.wu',
      'HR_ada.liu',
      'HR_honghui.xue',
      'admin',
      'HR_mary.wang'))) and t2.FUserID not in
      (select  FUserID from t_Group 
where FGroupID in 
(select FUserID from t_user
where FName in ('Supplier Approver')))
      Union  
      select 
      t1.FObjectType,
      t1.FObjectID,
      t1.FAccessMask,
      t1.FName as FTypeName,
      t2.FUserID,t2.FName as FUserName 
      from ( 
        select a.*,o.FName as FName 
        from t_AccessControl a,t_ObjectType o 
        where a.fObjectType=o.FObjectType and a.FObjectID=o.FObjectID) 
      t1,  
      (
        select g.FUserID,FGroupID,FName ,FUserTypeID
        from t_group g,t_user u 
        where g.fuserid=u.fuserid and u.FUserID>16394 ) 
      t2 
      where t1.FUserID=t2.FGroupID
       and (t2.FUserTypeID=10001 or (t2.FUserTypeID=10002
      and t2.FName in 
      ('HR_fiona.wu',
      'HR_ada.liu',
      'HR_honghui.xue',
      'admin',
      'HR_mary.wang'))) and t2.FUserID not in
      (select  FUserID from t_Group 
where FGroupID in 
(select FUserID from t_user
where FName in ('Supplier Approver')))
    ) 
    t3 , 
    t_ObjectAccessType t4  
    inner join 
    t_objectaccess w 
    on w.FObjectType = t4.FObjectType And w.FObjectID = t4.FObjectID 
    inner join t_GroupAccessType w2 
    on w.fgroupid=w2.fgroupid  
    Where not (t3.fobjecttype=3 and t3.fobjectid=20) 
    and  t3.FObjectType = t4.FObjectType 
    And t3.FObjectID = t4.FObjectID 
    and t4.FAccessUse<>262144 AND 
    t4.FAccessMask<>262144   
    and (t3.FAccessMask & t4.FAccessMask =t4.FAccessMask )  
    and t4.FName in ('新增','审核','查看','转交易供应商')
  
    and w2.FSubSys in (
      '基础资料','总账','固定资产','报表','职员管理',
      '现金管理','现金流量表','工资','应收账','应付账',
      '采购管理系统',
      '销售管理系统','费用预算','费用管理','供应商管理','日志管理')
    and t3.FTypeName in 
    ('差旅费报销',
     '出差（借款）申请',
     '费用（借款）申请',
     '费用报销单',
     '部门',
     
     '基础资料_币别',
     
     ----'要素费用',
     '要素项目',
     '采购订单',
     '采购发票',
     '采购申请单',
     '销售出库单',
     ----'工资发放表',
     '工资费用分配',
     ---'工资费用分配表',
     ----'工资公式设置',
     '工资汇总表',
     '工资计算',
     ---'工资结构分析',
     ---'职员基金台账',
     ---'职员台账表',
     ---'职员台账汇总表',
     '工资凭证管理',
     ---'工资所得税',
     ---'工资所得税报表',
     ---'工资条',
     ---'工资统计表',
     ---'工资项目',
     ---'工资账套参数',
     ---'基金汇总表',
     ---'基金计算',
     ---'基金计提变动情况表',
     ---'基金转出',
     ---'基金转入',
     ---'年龄工龄分析',
     ---'人力资源异动查询',
     ---'人员变动',
     ---'职员管理',
     ---'工资公式设置',
     '工资计算',
     '工资费用分配',
     ---'工资所得税',
     ---'人员变动一览表',
     ---'生成单据',
     ---'工资条',
     ---'银行代发表',
     ---'单据管理',
     ---'辅助资料',
     ---'银行管理',
     --'职员管理',
     ---'职员新增',
     ---'职员过滤方案设置',
     ---'基金计提标准设置',
     ---'基金计提方案设置',
     --'基金类型设置',
     ---'工资类别管理',
     ---'工资配款表',
     ---'部门管理',
     ---'查询过滤',
     ---'人事管理_组织架构管理',
     '供应商档案',
     '销售报价单',
     '销售订单',
     '销售发票',
     '销售费用发票',
     '发票',
     '其它应付单',
     '退款单',
     '预付单',
     '付款单',
     '付款申请单',
     '发票',
     '收款单',
     '退款单',
     '预收单',
     '核算项目分类总账',
     '核算项目汇总表',
     '核算项目明细表',
     '核算项目明细账',
     '核算项目余额表',
     '核算项目与科目组合表',
     '核算项目组合表',
     '科目余额表',
     '自动转账',
     '报表',
     '费用转移',
     '卡片及变动',
     '折旧管理',
     '资产领用单',
     '清理',
     '基础资料_核算项目类别',
     '基础资料_科目',
     '现金对账',
     '现金付款单',
     '现金盘点单',
     '现金收款单',
     '余额调节表',
     '附表项目',
     '附表项目调整',
     '现金流量查询',
     '总账_凭证',
     ----'所得项目设置',
     '凭证查询',
     '供应商档案'
    )
  ) r
  on r.FUserID=u.FUserID
  where   
  (u.FUserTypeID=10001 or (u.FUserTypeID=10002
      and u.FName in 
      ('HR_fiona.wu',
      'HR_ada.liu',
      'HR_honghui.xue',
      'admin',
      'HR_mary.wang'))) and u.FUserID not in
      (select  FUserID from t_Group 
where FGroupID in 
(select FUserID from t_user
where FName in ('Supplier Approver')))
  
  ----order by u.FName,r.FSubSys,r.FTypeName,r.FItemName
  
  union      
  
  
  
  select u.fname as 用户名, case when e.fnumber is null then '' else e.fnumber end  as 员工代码,
  case when e.fname  is null then '' else e.fname end as 员工姓名,
  case when r.FSubSys is null then '' else r.FSubSys end   as 模块,
  case when r.FTypeName is null then '' else r.FTypeName end as 功能,
  '审核'  as 职责,
  case FForbidden when 0 then '正常' else '禁用' end   as 状态,
  case when FirstLoginDate is null then  '' else convert(varchar(10),FirstLoginDate,120) end  用户启用日期 ,
  case when last_log_date is null then '' else convert(varchar(10),last_log_date,120)  end 用户最终登录日期
  
  
  from t_user  u
  inner join 
  (select FUserID,min(fdate) as FirstLoginDate,MAX(FDate) as last_log_date from t_Log  
    group by FUserID) data1
  on u.FUserID=data1.FUserID
  left join t_Emp e
  on  u.FEmpID=e.FItemID
  left join
  (select distinct 
    w2.FSubSys as FSubSys,
    --- w.FGroupid,
    --- t3.FObjecttype,
    --- t3.FObjectID,
    ---- t4.FIndex,
    t3.FTypeName,
    t4.FName as FItemName,
    --- t4.FDescription as FDescription,
    t3.FUserName,t3.FUserID
    from ( 
      select
      t1.FObjectType,
      t1.FObjectID,
      t1.FAccessMask,
      t1.FName as FTypeName,
      t2.FUserID,t2.FName as FUserName
      from (
        select a.*,o.FName as FName 
        from t_AccessControl a,t_ObjectType o 
        where a.fObjectType=o.FObjectType and a.FObjectID=o.FObjectID) 
      t1, --系统对象权限表
      (
        select FUserID,FName 
        from t_user  
        where fforbidden=0 
        AND (FUserID>16394 or (FUserID>9 and fuserid <16384 )) ) 
      t2 --所有用户列表
      where t1.FUserID=t2.FUserID  
      Union  
      select 
      t1.FObjectType,
      t1.FObjectID,
      t1.FAccessMask,
      t1.FName as FTypeName,
      t2.FUserID,t2.FName as FUserName 
      from ( 
        select a.*,o.FName as FName 
        from t_AccessControl a,t_ObjectType o 
        where a.fObjectType=o.FObjectType and a.FObjectID=o.FObjectID) 
      t1,  
      (
        select g.FUserID,FGroupID,FName 
        from t_group g,t_user u 
        where g.fuserid=u.fuserid and u.FUserID>16394 ) 
      t2 
      where t1.FUserID=t2.FGroupID
    ) 
    t3 , 
    t_ObjectAccessType t4  
    inner join 
    t_objectaccess w 
    on w.FObjectType = t4.FObjectType And w.FObjectID = t4.FObjectID 
    inner join t_GroupAccessType w2 
    on w.fgroupid=w2.fgroupid  
    Where not (t3.fobjecttype=3 and t3.fobjectid=20) 
    and  t3.FObjectType = t4.FObjectType 
    And t3.FObjectID = t4.FObjectID 
    and t4.FAccessUse<>262144 AND 
    t4.FAccessMask<>262144   
    and (t3.FAccessMask & t4.FAccessMask =t4.FAccessMask )  
    and t4.FName in ('查看')
    and w2.FSubSys in (
      '费用管理')
    and t3.FTypeName in 
    ('差旅费报销',
     '出差（借款）申请',
     '费用（借款）申请',
     '费用报销单'
     
    )
  ) r
  on r.FUserID=u.FUserID
  where r.FUserID  in
  (select FUserID from t_Group
   where FGroupID in 
   ( select FUserID from t_user where FName='Expenses Mgmt.')) 
     and   
  (u.FUserTypeID=10001 or (u.FUserTypeID=10002
      and u.FName in 
      ('HR_fiona.wu',
      'HR_ada.liu',
      'HR_honghui.xue',
      'admin',
      'HR_mary.wang'))) and u.FUserID not in
      (select  FUserID from t_Group 
where FGroupID in 
(select FUserID from t_user
where FName in ('Supplier Approver')))
) res
order by  用户名,模块  ,功能,职责


