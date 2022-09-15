-- Updated as of 15 September 2022

use HI3_Exalted_Abyss

-- change data type
update [dbo].[Data]
set [Date] = cast([Date] as date)

GO
-- change acroymns into actual names
drop table if exists #data_clean

select [Date]
      ,[Version]
      ,[Disturbance]
      ,coalesce(b.boss_name,a.[Last_Boss]) as [last_boss]
      ,coalesce(c.boss_name,a.[Final_Boss]) as [final_boss]
      ,[Rank]
      ,[Weather]
      ,coalesce(d.dps_name,a.[Main_dps]) as [main_dps]
      ,[Sub_weather]
      ,coalesce(e.boss_name,a.[Sub_boss]) as [sub_boss]
      ,coalesce(f.dps_name,a.[Sub_dps]) as [sub_dps]
	  ,[Points] 
	  ,[Change] 
	  ,[Final Trophy] 
into #data_clean
from [dbo].Data as a
left join
(select *
from [dbo].last_boss
	union 
	(select *
	from [dbo].final_boss)) as b
on a.Last_Boss = b.last_boss
left join
(select *
from [dbo].last_boss
	union 
	(select *
	from [dbo].final_boss))as c
on a.Final_Boss = c.last_boss
left join
[dbo].main_dps as d
on a.Main_dps = d.main_dps
left join
[dbo].sub_boss as e
on a.Sub_boss = e.sub_boss
left join
[dbo].main_dps as f
on a.Sub_dps = f.main_dps

GO
-- trim whitespaces
update #data_clean
set [Date]= ltrim(rtrim([Date]))
      ,[Version]= ltrim(rtrim([Version]))
      ,[Disturbance]= ltrim(rtrim([Disturbance]))
      ,[last_boss]= ltrim(rtrim([last_boss]))
      ,[final_boss]= ltrim(rtrim([final_boss]))
      ,[Rank]= ltrim(rtrim([Rank]))
      ,[Weather]= ltrim(rtrim([Weather]))
      ,[main_dps]= ltrim(rtrim([main_dps]))
      ,[Sub_weather]= ltrim(rtrim([Sub_weather]))
      ,[sub_boss]= ltrim(rtrim([sub_boss]))
      ,[sub_dps] = ltrim(rtrim([sub_dps]))
	  ,[Points] = ltrim(rtrim([Points]))
	  ,[Change] = ltrim(rtrim([Change]))
	  ,[Final Trophy] = ltrim(rtrim([Final Trophy]))
GO
-- check for duplicates
with count_check as (
select *,
		count(Date) over (partition by [Disturbance]
										,[Last_Boss]
										,[Final_Boss]
										,[Rank]
										,[Weather]
										,[Main_dps]
										,[Sub_weather]
										,[Sub_boss]
										,[Sub_dps]) as count_check
from #data_clean)
select *
from count_check
where count_check >1

-- data is extracted 
select *
from #data_clean
order by Date
