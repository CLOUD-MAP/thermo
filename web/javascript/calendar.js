function make_time_left(days) {
    if (days < -1) {
        return '<div class="timeLeft past">' + (-days).toFixed(0) + ' days ago</div>';
    } else if (days == -1) {
        return '<div class="timeLeft past">Yesterday</div>';
    } else if (days == 0) {
        return '<div class="timeLeft today" id="today">Today</div>';
    } else if (days == 1) {
        return '<div class="timeLeft future">Tomorrow</div>';
    } else if (days > 1) {
        return '<div class="timeLeft future">In ' + days.toFixed(0) + ' days</div>';
    }
}


function make_subject(subject) {
    emoticon = '';
    if (subject === undefined) {
        console.log('Subject is undefined?');
        return;
    }
    if (subject.indexOf('Lunch') >= 0) {
        //emoticon += ' &#x1F356;&#x1F35E;&#x1F379;&#x1F36A;';
        //emoticon += '&#x1F374;';
        emoticon = '&#x1F35E;';
    } else if (subject.indexOf('Pizza') >= 0 || subject.indexOf('Seminar') >= 0) {
        emoticon += '&#x1F355;';
    } else if (subject.indexOf('irthday') >= 0) {
        //emoticon += '&#x1F381;&#x1F388;';
        emoticon += '&#x1F381;';
    } else if (subject.indexOf('Break') >= 0) {
        emoticon += '&#x1F389;';
    } else if (subject.indexOf('100') >= 0) {
        emoticon += '&#x1F4AF;';
    } else if (subject.indexOf('Valentine') >= 0) {
        emoticon += '&#x1F49C;';
    } else if (subject.indexOf('Basket Ball') >= 0) {
        emoticon += '&#x1F3C0;';
    } else if (subject.indexOf('Graduation') >= 0) {
        emoticon += '&#x1F393;';
    } else if (subject.indexOf('Christmas') >= 0) {
        emoticon += '&#x1F384;';
    } else if (subject.indexOf('Patricks') >= 0) {
    	emoticon += '&#x1F340;';
    } else if (subject.indexOf('BBQ') >= 0) {
        emoticon += '&#x1F357;';
    }
    //return '<div class="subject">' + emoticon + (emoticon.length > 0 ? ' ' : '') + subject + '</div>';
    return '<div class="subject">' + subject + (emoticon.length > 0 ? ' ' : '') + emoticon + '</div>';
}

// Date.getDayOfYear() corrects for timezone offset. Not a wanted behavior when using UNIX time
function getDayOfYear(millisecondsSinceEpoch) {
    return Math.floor(millisecondsSinceEpoch / 86400000);
}

function process_php_result(result) {
    var now = new Date;
    //console.log('now ' + now.toString('ddd, MMMM d, yyyy h:mm:ss') + ' ==> ' +  Math.floor(now.getMinutes() / 15));
    if (previousResult == result &&
        previousDay == now.getDayOfYear() &&
        previousQuarter == Math.floor(now.getMinutes() / 15)) {
        console.log('Same content, skip refresh.');
		if (typeof window.webkit != 'undefined') {
			window.webkit.messageHandlers.screen.postMessage('http://arrc.ou.edu/calendar.html - calendar.js : process_php_result() - same content, skip refresh.');
		}
        return;
    }
    previousResult = result;
    previousDay = now.getDayOfYear();
    previousQuarter = Math.floor(now.getMinutes() / 15);

    // Parse out the PHP response into a key-dictionary array
    events = JSON.parse(result);
    
    // Some basic variables
    var latestDayOfYear = -1;
    var multiday = [];
    var theDay = 0;
    var d1 = new Date(theDay);
    var d2 = new Date(theDay);
	var days = -9999;
	var hours = 0;
	
    html = '';
    
    for (i=0; i<events.length; i++) {
        // Check if there are existing multi-day events left
        while (multiday.length > 0 && theDay <= events[i]['start']) {
            d1 = new Date(theDay + 43200000);
            if (debug)
                console.log('-- d1 @ ' + getDayOfYear(theDay) + '  latest @ ' + latestDayOfYear);
            if (latestDayOfYear != getDayOfYear(theDay)) {
                latestDayOfYear = getDayOfYear(theDay);
                days = latestDayOfYear - getDayOfYear(now.getTime());
// 				if (debug)
// 					console.log('days = ' + days);
//                 if (days <= -1) {
// 		            theDay += 86400000;
// 					if (debug)
// 						console.log('!! d1 @ ' + getDayOfYear(theDay)
// 									+ '  latest @ ' + latestDayOfYear
// 									+ '  ' + d1.toString('ddd, MMMM d, yyyy  h:mm:ss')
// 									+ ' <' + multiday.length + '>');
//                 	continue;
//                 }
                html += '<div class="day">';
                html += '<div class="date">' + d1.toString('dddd, MMMM d, yyyy') + '</div>';
                html += make_time_left(days);
                html += '</div>';
				if (debug)
					console.log('++ d1 @ ' + getDayOfYear(theDay)
								+ '  latest @ ' + latestDayOfYear
								+ '  ' + d1.toString('ddd, MMMM d, yyyy  h:mm:ss')
								+ ' <' + multiday.length + '>');
            }
            // console.log('skipped');
            for (j=0; j<multiday.length; j++) {
                hours = (multiday[j]['end'] - theDay) / 3600000;

                // Make a new slot
                html += '<div class="slot">';

                if (hours >= 24) {
                    html += '<div class="startTime">all-day</div>';
                    html += '<div class="endTime">&nbsp;</div>';
                } else {
                    html += '<div class="startTime">&nbsp;</div>';
                    if (hours > 0.25) {
                        var dd = new Date(multiday[j]['end']);
                        html += '<div class="endTime">' + dd.toString('h:mm tt') + '</div>';
                    } else {
                        html += '<div class="endTime">&nbsp;</div>';
                    }
                }

				if (debug) {
					console.log('.. d1 @ ' + getDayOfYear(theDay)
								+ '  latest @ ' + latestDayOfYear + '  ' + multiday[j]['subject']
								+ ' (' + d1.toString('ddd, MMMM d, yyyy h:mm:ss tt') + ')'
								+ ' [' + hours + ' / ' + j + ']');
				}

                html += make_subject(multiday[j]['subject'])
                      + '<div class="location">' + multiday[j]['location'] + '</div>'
                      + '</div>';
            }
            theDay += 86400000;
            // Go through that one more time to take out (splice) the expired events
            for (j=0; j<multiday.length; j++) {
                hours = (multiday[j]['end'] - theDay) / 3600000;
                if (hours < 24) {
                    multiday.splice(j, 1);
                }
            }
        }
        
        // Processing current event
        d1 = new Date(events[i]['start']);
        d2 = new Date(events[i]['end']);
        if (events[i]['location'] == null) {
            events[i]['location'] = '';
        }
        
        // Calculate number of hours of the event.
        // Display all day if it is a 24-hour event
        // Ignore the end time if it is less than or equal to 15 minutes
        hours = (events[i]['end'] - events[i]['start']) / 3600000;

		if (hours > 24) {
			multiday.push(events[i]);
			theDay = Math.floor(events[i]['start'] / 86400000) * 86400000 + 86400000;
			//theDay = d1.set({millisecond: 0, second: 0, minute: 0, hour: 0}).getTime() + 86400000;
			//theDay = events[i]['start'] + 86400000;
		}

        if (latestDayOfYear != getDayOfYear(events[i]['start'])) {
            latestDayOfYear = getDayOfYear(events[i]['start']);
            days = latestDayOfYear - getDayOfYear(now.getTime());
// 			if (debug)
// 				console.log('days = ' + days);
// 			if (days <= -1) {
// 				continue;
// 			}
			html += '<div class="day">'
				  + '<div class="date">' + d1.toString('dddd, MMMM d, yyyy') + '</div>';
			html += make_time_left(days);
			html += '</div>';
			if (debug)
				console.log(' + d1 @ ' + getDayOfYear(events[i]['start'])
							+ '  latest @ ' + latestDayOfYear
							+ '  ' + d1.toString('ddd, MMMM d, yyyy  h:mm:ss')
							+ ' <' + multiday.length + '>');
        }
//         if (days <= -1)
//         	continue;
        if (debug)
            console.log('   d1 @ ' + getDayOfYear(events[i]['start'])
                        + '  latest @ ' + latestDayOfYear + '  ' + events[i]['subject']
                        + ' (' + d1.toString('dddd, MMMM d, yyyy h:mm:ss tt') + ')');

        // Make a new slot
        if (now.getTime() >= events[i]['start'] &&
            now.getTime() <= events[i]['end'] &&
            hours < 12) {
            html += '<div class="slot now">';
        } else {
            html += '<div class="slot">';
        }

        if (hours >= 24) {
            html += '<div class="startTime">all-day</div>';
            html += '<div class="endTime">&nbsp;</div>';
        } else {
            html += '<div class="startTime">' + d1.toString('h:mm tt') + '</div>';
            if (hours > 0.25) {
                html += '<div class="endTime">' + d2.toString('h:mm tt') + '</div>';
            } else {
                html += '<div class="endTime">&nbsp;</div>';
            }
        }

        html += make_subject(events[i]['subject'])
              + '<div class="location">' + events[i]['location'] + '</div>'
              + '</div>';
    }

    document.getElementById('calendar').innerHTML = html;

	setTimeout(function() {    
	    o = document.getElementById('today');
        if (o) {
            $('html, body').animate({scrollTop: o.offsetParent.offsetTop}, 500);
        }
	}, 1000);
	
	//setTimeout('refresh_calendar()', 10000);
}

function refresh_calendar() {
    debug = 0;
    d = new Date;
    document.title = 'ARRC Calendar (Last updated ' + d.toString('yyyy/MM/dd h:mm:ss') + ')';
    $.ajax({
           type: 'GET',
           url: 'php/calendar.php',
           async: false,
           cache: false,
           timeout: 10000,
           success: function(result) { process_php_result(result); },
           error: function(error) { console.log('Error in $.ajax [' + error + ']'); }
    });
}


$(document).ready(function() {
                  previousDay = 0;
                  previousResult = '';
                  previousQuarter = -1;
                  refresh_calendar();
                  setInterval('refresh_calendar()', 10000);
                  //setTimeout('refresh_calendar()', 10000);
                  $('#fullScreenButton').click(function() {
                                               document.documentElement.webkitRequestFullscreen();
                                               });
                  });
