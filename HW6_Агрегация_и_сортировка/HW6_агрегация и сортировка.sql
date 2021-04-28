3. Определить кто больше поставил лайков (всего) - мужчины или женщины?

select count(*) from profiles where gender = "M";
select count(*) from profiles where gender = "F";
desc likes;
select count(*), gender 
from likes, profiles
where likes.user_id = profiles.user_id 
group by gender;

4. Подсчитать общее количество лайков десяти самым молодым пользователям (сколько лайков получили 10 самых молодых пользователей).

select count(*) from likes, (select user_id from profiles order by birthday desc limit 10) as youngs
where youngs.user_id = likes.target_id ;


5. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети
(критерии активности необходимо определить самостоятельно).

select first_name, last_name, activity from users, (
	select u as user, max(activity) as activity
	from (
		select user_id as u, created_at as activity from likes
		union all
		select user_id as u, ifnull(updated_at, created_at) as activity from media
		union all
		select from_user_id as u, created_at as activity from messages
	) as all_activities
	group by u
	order by activity asc limit 10
) as temp where users.id = temp.user