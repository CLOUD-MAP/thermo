var idx = 0;
var ppi_prod = 0;
var radar_id = 0;
var prev_ppi_prod = 0;
var fetch_time = 500;
var ireq = 0;
var prev_ireq = 0;
var loc = window.location.toString().toLowerCase();
var is_iphone = (loc.indexOf('iphone')!=-1);
var prodnames = new Array('Reflectivity','Doppler Velocity','Spectrum Width','Differential Reflectivity','Differential Phase','Correlation Coefficient');
var dnum = new Date();
var age = 0;
var php2run = 'filelist.php';
var NFRAME = 15;
var anim = false;
var T = 150;
var prev_az = 0.0;
var abs_az = 0.0;
var prev_abs_az = 0.0;
var use_turn = 0;
var i = 0;
var imglist = new Array(2);
imglist[0] = new Array(); // For legacy moment
imglist[1] = new Array(); // For OU-PRIME moment
for (i=0; i<6; i++) {
	imglist[0][i] = new Array(NFRAME); // Filelist contains up to 15 files
	imglist[1][i] = new Array(NFRAME);
}
var ppi_image = new Array();
for (i=0; i<NFRAME; i++) {ppi_image[i] = new Image();}
var filelist_time;
var tdiff = 0;

$(document).ready(function() {
	var agent = navigator.userAgent.toLowerCase();
	var compat = (agent.indexOf('webkit')>0 || agent.indexOf('firefox/3.5')>0 || agent.indexOf('firefox/4')>0 || agent.indexOf('presto/2')>0);
	if (!compat) {
		var o = document.getElementById('circle');
		if (o) {
			var l =	document.getElementById('circle').parentNode;
			if (l) l.removeChild(document.getElementById('circle'));
		}
	}
	if (!is_iphone)
		compat |= (agent.indexOf('mozilla')!=-1);
	if (compat) {
		if (loc.indexOf('dev.html')!=-1) {
			document.getElementById('title').innerHTML = 'Radar (dev)';
		}
		refresh_operate_status_and_filelist();
		if (agent.indexOf('webkit')>0) {
			var o = document.getElementById('antenna');
			if (o)
				o.style.webkitTransitionDuration = (fetch_time+50)/1000+'s';
		} else {
			use_turn = 1;
		}
		// This is the update the weather widget, top bar info
		updateInfo();
		// A wrapper to update radar filelist and status
		update_components();
	} else {
		document.getElementsByTagName('body')[0].innerHTML = 
			'<center><br/><br/><br/><br/><br/><font color=white size=+1>'+
			'Sorry, Your browser is not compatible<br/><br/>'+agent+'</font>';
	}
});

function update_components() {
	refresh_operate_status_and_filelist();
	setTimeout('update_components()', 10000);
}

function get_age() {
	var tmps = imglist[radar_id][ppi_prod][idx];
//	document.getElementById('debug').innerHTML = 'tmps = '+tmps;
	if (tmps) {
		// Get the YYYYMMDD-hhmmss
		var patt=/20[0-9][0-9][0-1][0-9][0-3][0-9]-[012][0-9][0-5][0-9][0-5][0-9]/;
		//document.getElementById('debug').innerHTML = patt + '  ' + tmps;
		tmps = patt.exec(tmps).toString();
		//document.getElementById('debug').innerHTML = tmps;
		dnum = new Date(Date.UTC(tmps.substr(0,4),tmps.substr(4,2)-1,tmps.substr(6,2),tmps.substr(9,2),tmps.substr(11,2),tmps.substr(13,2)));
	} else {
		tmps = 'Unknown';
		dnum = new Date();
	}
	var now = new Date();
	age = (now-dnum-tdiff)/60000;
	var min = Math.floor(age);
	var sec = (Math.floor((age-min)*60)).toString();
	if (sec.length==1)
		sec = '0'+sec;

	if (min < 1)
		document.getElementById('age').innerHTML = '< 1 minute ago';
	else if (min == 1)
		document.getElementById('age').innerHTML = '1 minute ago';
	else if (min > 10080)
		document.getElementById('age').innerHTML = '> a week';
	else if (min > 2880)
		document.getElementById('age').innerHTML = '> ' + Math.floor(min/1440)+' days ago';
	else if (min > 60)
		document.getElementById('age').innerHTML = '> ' + Math.floor(min/60) + ' hours ago';
	else
		document.getElementById('age').innerHTML = min+' minutes ago';
//	document.getElementById('debug').innerHTML = 'Debug message: '+dnum.toString()+'<br>'+now.toString();
}

function refresh_operate_status_and_filelist() {
	// Status of operate or standby
	$.ajax({
		type: 'GET',
		url: '/px1000/status/live/statmsg',
		async: true,
		cache: false,
		timeout: 10000,
		success: function(ret) {
			// Ready
			var x = ret.split(';');
			x.forEach(function(c) {
				if (c.match(/Operate/)) {
					n = c.match(/\d+$/)[0];
					var o = document.getElementById('message');
					if (n == 3) {
						document.getElementById('topbar_overlay').style.backgroundColor = 'lime';
						if (o)
							o.innerHTML = '<ul><li>Radar Operating</li></ul>';
					} else if (n == 2) {
						document.getElementById('topbar_overlay').style.backgroundColor = 'gold';
						if (o)
							o.innerHTML = '<ul><li>Radar Standby</li></ul>';
					} else if (n == 1) {
						document.getElementById('topbar_overlay').style.backgroundColor = 'red';
						if (o)
							o.innerHTML = '<ul><li>Radar Off</li></ul>';
					} else if (n == 0) {
						document.getElementById('topbar_overlay').style.backgroundColor = 'gray';
						if (o)
							o.innerHTML = '<ul><li>Communication Error</li></ul>';
					}
				}
			});
		},
		error: function() {
			//document.getElementById('debug').innerHTML = 'Error retrieving stat msg';
			console.log('Error retrieving stat_msg');
		}
	});
	// Latest filelist
	$.ajax({
		type: 'GET',
		url: php2run,
		async: true,
		cache: false,
		timeout: 10000,
		success: function(ret) {
			var m = ret.split(';');
			var i = 0;
			var r = 0;
			var c = 0;
			while (c<m.length-2) {
				var num = parseInt(m[c++],10);
				for (var j=0; j<num && c<m.length-1; j++) {
					// radar, moment, frame
					imglist[r][i][j] = m[c++];
				}
				i++;
				// 6 moments per radar
				if (i==6) {
					r++;
					i = 0;
				}
			}
			filelist_time = m[c];
			tdiff = (new Date()).getTime() - 1000 * filelist_time;
			/*
			document.getElementById('debug').innerHTML = 'c = ' + c + '/' + m.length + '<br />' +
			' server time = ' + filelist_time + '<br />' +
			' client time = ' + (new Date()).getTime()/1000 + '<br />' +
			' tdiff = ' + tdiff + 'ms';
			*/
			update_ppi();
		},
		error: function() {
			console.log('Error getting filelist');
		}
	});
}

function turn_antenna(angle,delta,time,steps,ii) {
	new_angle = angle+delta;
	o = document.getElementById('antenna');
	o.style.webkitTransform = 'rotate('+new_angle+'deg)';
	o.style.MozTransform = 'rotate('+new_angle+'deg)';
//	document.getElementById('debug').innerHTML = 'ii:'+ii+'  prev_ireq:'+prev_ireq+'<br />'+'turning to:'+Math.floor(10*new_angle)/10+' d:'+delta+' steps:'+steps+' t:'+time;
	if (steps>0 && ii==prev_ireq)
		setTimeout('turn_antenna(new_angle,'+delta+','+time+','+(steps-1)+','+ii+')',time);
}


function animate_ppi() {
	var i;
	var all_complete = 0;
	if (anim) {
		var tmp = document.getElementById('play');
		if (tmp)
			tmp.src = '/images/stop.png';
		// Assign the array only if needed
		i = NFRAME - 1;
		if (ppi_image[i].src != imglist[radar_id][ppi_prod][i]) {
			for (i=0; i<NFRAME; i++) {
				if (typeof(imglist[radar_id][ppi_prod][i])=='undefined') {
					ppi_image[i].src = 'images/blank.png';
				} else {
					ppi_image[i].src = imglist[radar_id][ppi_prod][i];
				}
			}
		}
		// Check if all images are loaded
		var loaded_str = '';
		for (i=0; i<NFRAME; i++) {
            if (ppi_image[i].complete) {
                loaded_str += '1';
                all_complete++;
            } else {
                loaded_str += '0';
            }
		}
		console.log(loaded_str);
		var o = document.getElementById('loading'); 
		if (all_complete >= NFRAME - 2) {
			prev_ppi_prod = ppi_prod;
			o.style.visibility = 'hidden';
			loop_ppi();
		} else {
			o.style.visibility = 'visible';
			setTimeout('animate_ppi()',250);
		}
	} else {
		idx = 0;
		update_ppi();
		tmp = document.getElementById('play');
		if (tmp)
			tmp.src = '/images/play.png';
	}
	
}

function loop_ppi() {
	if (anim && prev_ppi_prod==ppi_prod) {
		if (idx <= 0) {
			idx = NFRAME-1;
		} else
			idx--;
		update_ppi();
		if (idx == 0)
			setTimeout('loop_ppi()',1500);
		else
			setTimeout('loop_ppi()',T);
	} else {
		document.getElementById('loading').innerHTML = 'Switched';
		animate_ppi();
	}
}

function update_ppi() {
	// Get the correct image source
	if (typeof(imglist[radar_id][ppi_prod][idx])=='undefined') {
		img_src = 'images/blank.png';
	} else {
		img_src = imglist[radar_id][ppi_prod][idx];
	}
	// Only change the source if needed
	if (ppi_image[idx].src != img_src) {
		ppi_image[idx].src = img_src;
		check_load();
	}
	get_age();
	document.getElementById('ppi').src = ppi_image[idx].src;
	var o = document.getElementById('ppi_moment');
	if (o)
		o.innerHTML = prodnames[ppi_prod];
}

function check_load() {
	var o = document.getElementById('loading'); 
	if (!ppi_image[idx].complete) {
		o.style.visibility = 'hidden';
		setTimeout('check_load()', 250);
	} else {
		o.style.visibility = 'visibile';
	}
}

function switch_moment() {
	if (arguments.length>0) {
		ppi_prod = arguments[0];
		update_ppi();
	}
}

function cycle_ppi_prod() {
	if (ppi_prod==5)
		ppi_prod = 0;
	else
		ppi_prod++;
	update_ppi();
}

function prev_frame() {
	idx = idx+1;
	if (idx>NFRAME-1)
		idx = 0;
	update_ppi();
}

function next_frame() {
	idx = idx-1;
	if (idx<0)
		idx = NFRAME-1;
	update_ppi();
}
