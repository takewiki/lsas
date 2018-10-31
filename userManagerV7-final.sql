go
alter view takewiki_kingdee_list as 
select distinct w2.FSubSys as FSubSys,w.FGroupid,t3.FObjecttype,
t3.FObjectID,t4.FIndex,t3.FTypeName,t4.FName as FItemName,
t4.FDescription as FDescription,t3.FUserName ,t3.FUserID
from ( select t1.FObjectType,t1.FObjectID,t1.FAccessMask,
t1.FName as FTypeName,t2.FUserID,t2.FName as FUserName 
from (select a.*,o.FName as FName 
from t_AccessControl a,t_ObjectType o where a.fObjectType=o.FObjectType and a.FObjectID=o.FObjectID)
 t1,  (select FUserID,FName from t_user 
  where 
  ---fforbidden=0 AND 
  
  (FUserID>16394 or (FUserID>9 and fuserid <16384 )) ) t2 
  where t1.FUserID=t2.FUserID  Union  select t1.FObjectType,t1.FObjectID,t1.FAccessMask,t1.FName 
  as FTypeName,t2.FUserID,t2.FName as FUserName from (select a.*,o.FName as FName 
  from t_AccessControl a,t_ObjectType o where a.fObjectType=o.FObjectType and a.FObjectID=o.FObjectID) t1,  
  (select g.FUserID,FGroupID,FName from t_group g,t_user u where g.fuserid=u.fuserid and u.FUserID>16394 ) 
  t2 where t1.FUserID=t2.FGroupID) t3 , t_ObjectAccessType t4  
  inner join t_objectaccess w on w.FObjectType = t4.FObjectType And w.FObjectID = t4.FObjectID inner join 
  t_GroupAccessType w2 on w.fgroupid=w2.fgroupid 
  
   Where not (t3.fobjecttype=3 and t3.fobjectid=20) and 
   t3.FObjectType = t4.FObjectType And t3.FObjectID = t4.FObjectID and t4.FAccessUse<>262144 AND 
   t4.FAccessMask<>262144   and (t3.FAccessMask & t4.FAccessMask =t4.FAccessMask ) 

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
    ) and t4.FName in ('新增','审核','查看','转交易供应商')
    and t3.FUserID not in (select  distinct FGroupID from t_Group)
    
    
    
   -----table 1 
 ---- select * from takewiki_kingdee_list
  
  ---table2
  go
 alter view  takewiki_user_loginDate as 
  select FUserID,isnull(convert(varchar(10),MIN(FDate),120),'') as FStartDate,
                 isnull(convert(varchar(10),MAX(fdate),120),'') as FLastLoginDate from t_Log
  group by FUserID
  
 
  ----select * from takewiki_user_loginDate
  ---
  go
  alter view takewiki_user_emp as 
  select u.FUserID,ISNULL(e.FNumber,'')  as FEmpNumber,
  ISNULL(e.FName,'') as FEmpName,
  FForbidden as FStatus  from t_user u 
  left join t_Emp  e
  on u.FEmpID=e.FItemID
  
  go
alter  view takewiki_kingdeeUserList as
  select distinct a.FSubSys,a.FTypeName ,
  case  a.FItemName when '转交易供应商' then '审核' else a.FItemName  end  as FItemName , a.FUserName,b.FEmpName,b.FEmpNumber,c.FStartDate,c.FLastLoginDate,b.FStatus  from  takewiki_kingdee_list a
  inner join takewiki_user_emp b 
  on a.FUserID=b.FUserID
  left join takewiki_user_loginDate c 
  on a.FUserID=c.FUserID
  where b.fstatus=0
  
 go
 
 select FUserName   as  用户名  ,
        FEmpNumber  as   员工代码 ,
        FEmpName    as   员工姓名,
        FSubSys     as  模块,
        FTypeName   as  功能,
        FItemName   as  职责,
        case fstatus when 0 then '正常' else '禁用' end as  状态,
        FStartDate as 启用日期,
        FLastLoginDate as 最近登陆日期
        
  from takewiki_kingdeeUserList
 order by FUserName,FSubSys,FTypeName,FItemName
 
    
