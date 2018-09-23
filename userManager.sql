select u.fname as 用户名, case when e.fnumber is null then '' else e.fnumber end  as 员工代码,
case when e.fname  is null then '' else e.fname end as 员工姓名,
case FForbidden when 0 then '正常' else '禁用' end   as 状态,
fcreatetime 用户启用日期 ,last_log_date 用户最终登录日期 from t_user  u
inner join 
(select FUserID,MAX(FDate) as last_log_date from t_Log  
group by FUserID) data1
on u.FUserID=data1.FUserID
left join t_Emp e
on  u.FEmpID=e.FItemID

---增加一个功能模板处理即可。
