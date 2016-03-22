<?php
/**
 * @package HelpDeskZ
 * @website: http://www.helpdeskz.com
 * @community: http://community.helpdeskz.com
 * @author Evolution Script S.A.C.
 * @since 1.0.0
 */
$q = $db->query("SELECT * FROM ".TABLE_PREFIX."news ORDER BY date DESC LIMIT 3");
while($r = $db->fetch_array($q)){
	$lastestnews[] = $r;
}
$q= $db->query("SELECT * FROM ".TABLE_PREFIX."login_log WHERE staff_id=".$staff['id']." ORDER BY date DESC LIMIT 10");
while($r = $db->fetch_array($q)){
	$login_log[] = $r;
}
$q = $db->query("SELECT * FROM ".TABLE_PREFIX."departments");
while($r = $db->fetch_array($q)){
	if(in_array($r['id'],$staff_departments)){
		$departments[$r['id']] = $r['name'];
	}else{
		$exceptiondep_query .= " AND department_id!={$r['id']}";
	}
}
/*
$tickets_summary = $db->fetchRow("SELECT
	(SELECT COUNT(id) FROM ".TABLE_PREFIX."tickets WHERE trash = 0 AND status='1' {$exceptiondep_query}) AS open,
	(SELECT COUNT(id) FROM ".TABLE_PREFIX."tickets WHERE trash = 0 AND status='2' {$exceptiondep_query}) as answered,
	(SELECT COUNT(id) FROM ".TABLE_PREFIX."tickets WHERE trash = 0 AND status='3' {$exceptiondep_query}) as awaiting_reply,
	(SELECT COUNT(id) FROM ".TABLE_PREFIX."tickets WHERE trash = 0 AND status='4' {$exceptiondep_query}) as in_progress,
	(SELECT COUNT(id) FROM ".TABLE_PREFIX."tickets WHERE trash = 0 AND status='5' {$exceptiondep_query}) as closed"
);
*/
$q = $db->query("SELECT id, LOWER(langstring) AS status FROM ".TABLE_PREFIX."ticket_status");
while($r = $db->fetch_array($q)){
	$ticket_statusses[ $r['id'] ] = $r['status'];
}
foreach($ticket_statusses AS $id => $status) {
	$tickets_summary_string[] = "(SELECT COUNT(id) FROM ".TABLE_PREFIX."tickets WHERE trash = 0 AND status='".$id."' {$exceptiondep_query}) AS ".$status;
}
$tickets_summary = $db->fetchRow("SELECT " . implode(',',$tickets_summary_string));

$template_vars['lastestnews'] = $lastestnews;
$template_vars['login_log'] = $login_log;
$template_vars['tickets_summary'] = $tickets_summary;
$template = $twig->loadTemplate('dashboard.html');
echo $template->render($template_vars);
$db->close();
exit;
?>
