use  AIS20160422080603
go


select u.fname as 'Kingdee user name', 
case when e.fnumber is null then '' else e.fnumber end  as 'Employee ID',
case when e.fname  is null then '' else e.fname end as 'Employee Name',
case r.FSubSys when '基础资料' then 'Master Data'
               when '总账' then 'General Ledger'
               when '固定资产' then 'Fixed Assets'
               when  '报表' then 'Report'
               when  '现金管理' then 'Cash'
               when  '现金流量表' then 'Cash Flow Statement'
               when  '工资' then 'Payroll'
               when '应收账' then 'A/R'
               when '应付账' then 'A/P'
               when '采购管理系统' then 'Purchase'
               when '仓存管理系统' then 'Inventory'
               when '存货核算管理系统' then 'Inventory Accounting'
               when '销售管理系统' then 'Sales'
               when '费用预算' then 'Expense Budget'
               when '费用管理' then 'Expense Management'
               when '供应商管理' then 'SRM'
               when '日志管理' then 'Log Management'  else '' end   as 'Kingdee Function',
case r.FItemName when '查看' then 'Read Only' when '新增' then 'Input' when '审核' then 'Approval'  else '' end   as 'Role',
case FForbidden when 0 then 'Active' else 'Inactive' end   as 'Current Status',
convert(varchar(10),fcreatetime,120) as 'Date of Access Granted' ,
convert(varchar(10),last_log_date,120)  as 'Date of last log-in'


 from t_user  u
inner join 
(select FUserID,MAX(FDate) as last_log_date from t_Log  
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
    ---t3.FTypeName,
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
      and t4.FName in ('新增','审核','查看')
      and w2.FSubSys in (
       '基础资料','总账','固定资产','报表',
 '现金管理','现金流量表','工资','应收账','应付账',
 '采购管理系统','仓存管理系统','存货核算管理系统',
 '销售管理系统','费用预算','费用管理','供应商管理','日志管理')
) r
 on r.FUserID=u.FUserID
 order by u.FName,r.FSubSys,r.FItemName
 
 
 
 



