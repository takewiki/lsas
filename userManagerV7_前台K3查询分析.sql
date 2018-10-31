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
 