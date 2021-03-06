
select u.fname as 用户名, case when e.fnumber is null then '' else e.fnumber end  as 员工代码,
case when e.fname  is null then '' else e.fname end as 员工姓名,
case when r.FSubSys is null then '' else r.FSubSys end   as 功能模块,
case when r.FItemName  is null then '' else r.FItemName end   as 职责,
case FForbidden when 0 then '正常' else '禁用' end   as 状态,
convert(varchar(10),fcreatetime,120) 用户启用日期 ,
convert(varchar(10),last_log_date,120) 用户最终登录日期


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
 
 
 
 



