/* people.js  Copyright (c) 2014 Boon Leng Cheong */

// Global variables
var phd_param = 0;
var phd_students;
var ms_param = 0;
var ms_students;

function isIE () {
  var myNav = navigator.userAgent.toLowerCase();
  return (myNav.indexOf('msie') != -1) ? parseInt(myNav.split('msie')[1]) : false;
}

function load_binary_data(url) {
	var req = new XMLHttpRequest();
	if (req) {
		var browser_is_IE = isIE();
		req.open('GET', url, false);
		if (req.overrideMimeType)
			req.overrideMimeType('text/plain; charset=x-user-defined');
		if (browser_is_IE) {
			req.responseType = 'arraybuffer';
		}
		req.send(null);
		if (req.status != 200)
			return null;
		if (browser_is_IE) {
			return Uint8Array(req.response);
		} else {
			return req.responseText;
		}
	}
	return null;
} 

function format_phone(number) {
	raw_number = number.replace(/[^\d]/g, ''); // Get rid of non-numbers
	return raw_number.replace(/(\d{3})(\d{3})(\d{4})/, '($1) $2-$3');
}

function people_cells(rows) {
	var text = [];
	rows.forEach(function(row) {
		var line = '  <li>\n';
		if (row['URL'])
			line += '<a href="' + row['URL'] + '" target="_new">\n';
		line += '<img src="people_images/' + (row['hasPic'] ? row['Email'] : 'blank') + '.jpg" />\n';
		line += '<span class="name">' + row['First Name'] + ' ' + row['Last Name'] + '</span><br />';
		if (row['URL'])
			line += '</a>';
		line += '<i>'
		line += row['Title'];
		if (row['Title 2'])
			line += ',<br />' + row['Title 2'];
		line += '</i><br />';
		line += row['Affiliation'] + '<br />';
		if (row['Place'])
			line += row['Place'] + '<br />';
		if (row['Phone'])
			line += format_phone(row['Phone']) + '<br />';
		line += '<a href="mailto:' + row['Email'] + '">' + row['Email'].toLowerCase() + '</a>';
		line += '</li>';
		text.push(line);
	});
	return text.join('\n');
}

// ---------------------------- Function objects -------------------------
sort_lastname = function(a, b) {
	var x = a['Last Name'].toLowerCase()+a['First Name'].toLowerCase();
	var y = b['Last Name'].toLowerCase()+b['First Name'].toLowerCase();
	return ((x<y)?-1:((x>y)?1:0));
}

sort_firstname = function(a, b) {
	var x = a['First Name'].toLowerCase()+a['Last Name'].toLowerCase();
	var y = b['First Name'].toLowerCase()+b['Last Name'].toLowerCase();
	return ((x<y)?-1:((x>y)?1:0));
}

sort_affil = function (a, b) {
	var x = a['Affiliation'].toLowerCase()+a['Last Name'].toLowerCase()+a['First Name'].toLowerCase();
	var y = b['Affiliation'].toLowerCase()+b['Last Name'].toLowerCase()+b['First Name'].toLowerCase();
	return ((x<y)?-1:((x>y)?1:0));
}

sort_place = function(a, b) {
	var x = a['Place'].toLowerCase()+a['Last Name'].toLowerCase()+a['First Name'].toLowerCase();
	var y = b['Place'].toLowerCase()+b['Last Name'].toLowerCase()+b['First Name'].toLowerCase();
	return ((x<y)?-1:((x>y)?1:0));
}

sort_advisor = function(a, b) {
	if (a['Advisor'] && b['Advisor']) {
		var x = a['Advisor'].toLowerCase();
		var y = b['Advisor'].toLowerCase();
		return ((x<y)?-1:((x>y)?1:0));
	} else if (a['Advisor']) {
		return 1;
	} else if (b['Advisor']) {
		return -1;
	} else {
		return 0;
	}
}

function insert_students(phd_or_ms, param, auto) {
	type_str = phd_or_ms == 0 ? '0' : '1';
	html = '<li>'+
	       '<span class="name"><a onclick="insert_students(' + type_str + ', sort_lastname, true)">Name</a></span>'+
		   '<span class="room"><a onclick="insert_students(' + type_str + ', sort_place)">Location</a></span>'+
		   '<span class="affil"><a onclick="insert_students(' + type_str + ', sort_affil)">Affiliation</a></span>'+
		   '<span class="adv"><a onclick="insert_students(' + type_str + ', sort_advisor)">Primary Advisor</a></span>'+
		   '<span class="email">Email</span></li>';

	if (auto == undefined) {
		auto = false;
	}
	// in auto mode, param can be sort_lastname or sort_lastname
	if (auto && (param == sort_firstname || param == sort_lastname)) {
		if ( (phd_or_ms == 0 && phd_param == sort_firstname) || (phd_or_ms == 1 &&  ms_param == sort_firstname) ) {
			// this mean it was using first name and name is clicked again, override param
			param = sort_lastname;
		} else if ( (phd_or_ms == 0 && phd_param == sort_lastname) || (phd_or_ms == 1 &&  ms_param == sort_lastname) ) {
			param = sort_firstname;
		}
	}
	if (phd_or_ms == 0) {
		phd_param = param;
		phd_students.sort(param);
		document.getElementById('phd_students').innerHTML = html + make_student_html_list(phd_students);
	} else if (phd_or_ms == 1) {
		ms_param = param;
		ms_students.sort(param);
		document.getElementById('ms_students').innerHTML = html + make_student_html_list(ms_students);
	}
}

function file_exists(url) {
	var http = new XMLHttpRequest();
	http.open('HEAD', url, false);
	http.send();
	return http.status != 404;
}

function show_popup(name, place, affil, email, a1, a2, h) {
	var o = document.getElementById('name_card');
	var affil_full = '';
	if (o) {
		switch (affil) {
			case 'SoM':
				affil_full = 'School of Meteorology';
				break;
			case 'ECE':
				affil_full = 'School of Electrical and Computer Engineering';
				break;
			case 'CEES':
				affil_full = 'School of Civil Engineering and Environmental Science';
				break;
			case 'CS':
				affil_full = 'School of Computer Science';
				break;
			default:
				break;
		}
		
		var img_src = (h) ? ("people_images/" + email + ".jpg") : "people_images/blank.jpg";
				
//		if (!file_exists(img_src))
//			img_src = "/people_images/blank.jpg";
		
		var html_str = "<span class=\"name_card_name\">" + name + "</span>"
		             + "<img class=\"name_card_img\" src=\"" + img_src + "\" /><br />"
					 + affil_full + "<br />" + place + "<br /><a href=\"mailto:" + email + "\">" + email + "</a>";
					
		
		//html_str += "<br /><span id=\"debug\"></span>"
		
		if (a1.length > 0) {
			if (a2.length > 0) {
				html_str += '<br /><br />\nAdvisors: ' + a1 + ', ' + a2;
			} else {
				html_str += '<br /><br />\nAdvisor: ' + a1;
			}
			o.style.height = '190px';
		} else {
			o.style.height = '160px';
		}
		
		o.innerHTML = html_str;
		o.style.visibility = 'visible';
		o.style.opacity = '1.0';
	}	
}

function hide_popup() {
	document.getElementById('name_card').style.opacity = '0';
	document.getElementById('name_card').style.visibility = 'hidden';
}

function make_student_html_list(students) {
	var html = '';
    for (ii in students) {
        var student = students[ii];
        var fullname = '', advisor = '', a1 = '', a2 = '', place = '', affil = '', email = '';
        if (student['First Name']) {
            fullname += student['First Name'].trim();
        }
        if (student['Last Name']) {
            fullname += (fullname.length > 0 ? ' ' : '') + student['Last Name'].trim();
        }
        if (student['Advisor']) {
            a1 = student['Advisor'].trim();
            if (student['Advisor 2']) {
                a2 = student['Advisor 2'].trim();
            }
        }
        if (student['Place']) {
            place = student['Place'].trim();
        } else {
            place = ' ';
        }
        if (student['Affiliation']) {
            affil = student['Affiliation'].trim();
        } else {
            affil = '-';
        }
        if (student['Email']) {
            email = student['Email'].trim();
        } else {
            email = '';
        }
		html += '<li onClick="show_popup(\'' +
			fullname + '\', \'' +
			place + '\', \'' +
			affil + '\', \'' +
			email + '\', \'' +
			a1 + '\', \'' + a2 + '\', '+ student['hasPic'] + ')"' +
			' onBlur="hide_popup()">' +
			'<span class="name">' + fullname + '</span>' +
			'<span class="room">' + place + '</span>' +
			'<span class="affil">' + affil + '</span>'+
			'<span class="adv">' + a1 + '</span>' +
			'<a href="mailto:' + email + '">' + email + '</a></li>\n';
    }
	return html;
}

function make_alumni_html_list(peoples) {
	html = '<li><span class="name">Name</span><span class="degree">Degree</span>Affiliation</li>\n';
	peoples.forEach(function(people) {
		html += '<li><span class="name">' + people['First Name'].trim() + ' ' + people['Last Name'].trim() + '</span>';
		html += '<span class="degree">' + people['Degree'].trim() + ' ' + people['Major'].trim() + ', ' + people['Year'].trim() + '</span>';
		html += people['Future'].trim() + '</li>\n'
	});
	return html;
}

function make_past_html_list(peoples) {
	/** html = '<li><span class="name">Name</span><span class="degree">Period</span>Affiliation</li>\n'; */
	html = '<li><span class="name">Name</span><span class="degree">Period</li>\n';
	peoples.forEach(function(people) {
		html += '<li><span class="name">' + people['First Name'].trim() + ' ' + people['Last Name'].trim() + '</span>';
		html += '<span class="degree">' + people['Period'].trim() + '</li>\n'
	/**	html += '<span class="degree">' + people['Period'].trim() + '</span>';
		html += people['Future'].trim() + '</li>\n' */
	});
	return html;
}

function populate_people_page_xlsx() {
	var raw_data = load_binary_data('/people.xlsx');

//	if (isIE())
//		document.getElementById('debug').innerHTML = raw_data.length;

	var wb = XLSX.read(raw_data, {type: 'binary'});
	
	document.getElementById('faculty').innerHTML = 
	people_cells(XLSX.utils.sheet_to_row_object_array(wb.Sheets['Faculty']));
	
	document.getElementById('staff').innerHTML = 
	people_cells(XLSX.utils.sheet_to_row_object_array(wb.Sheets['Engineering Staff']));

	document.getElementById('postdocs').innerHTML = 
	people_cells(XLSX.utils.sheet_to_row_object_array(wb.Sheets['Postdocs']));

	document.getElementById('affiliates').innerHTML = 
	people_cells(XLSX.utils.sheet_to_row_object_array(wb.Sheets['Affiliates']));

	document.getElementById('advisory').innerHTML =
	people_cells(XLSX.utils.sheet_to_row_object_array(wb.Sheets['Advisory']));

	phd_students = XLSX.utils.sheet_to_row_object_array(wb.Sheets['PhD Students']);
	ms_students = XLSX.utils.sheet_to_row_object_array(wb.Sheets['MS Students']);
	
	insert_students(0, sort_lastname);

	insert_students(1, sort_lastname);

	document.getElementById('alumni').innerHTML = 
	make_alumni_html_list(XLSX.utils.sheet_to_row_object_array(wb.Sheets['Alumni']));

	document.getElementById('past_postdocs').innerHTML =
	make_past_html_list(XLSX.utils.sheet_to_row_object_array(wb.Sheets['Past']));
}

/*
function populate_people_page() {
	var req = new XMLHttpRequest();
	if (req) {
		var handle_complete = function() {
		
			sh = jQuery.parseJSON(req.responseText);

//			document.getElementById('debug').innerHTML = Object.keys(sh);
		
			document.getElementById('faculty').innerHTML = people_cells(sh['Faculty']);
			document.getElementById('technical_staff').innerHTML = people_cells(sh['Technical Staff']);
			document.getElementById('administrative_staff').innerHTML = people_cells(sh['Administrative Staff']);
			document.getElementById('postdocs').innerHTML = people_cells(sh['Postdocs']);
			document.getElementById('affiliates').innerHTML = people_cells(sh['Affiliates']);

			phd_students = sh['PhD Students']; insert_students(0, sort_lastname);
			ms_students = sh['MS Students']; insert_students(1, sort_lastname);
		
			document.getElementById('alumni').innerHTML = make_alumni_html_list(sh['Alumni']);
			document.getElementById('past_postdocs').innerHTML = make_past_html_list(sh['Past']);
		}
		var handle_error = function() {
			document.getElementById('debug').innerHTML = 'Retrieval failed.';
		}
		req.open('GET', 'php/people.php', true);        // Use this for PHP 5 >= 5.2

		req.addEventListener('load', handle_complete, false);
		req.addEventListener('error', handle_error, false);
		req.send(null);
	} else {
		document.getElementById('debug').innerHTML = 'XHR Not Available.';
	}
}
*/

function populate_people() {
    var req = new XMLHttpRequest();
    if (req) {
        var handle_complete = function() {
            
            sh = jQuery.parseJSON(req.responseText);
            
            html = '';
            
            for (var section in sh) {
                // console.log(section);
                if (section.indexOf('Un')       == 0 ||
                    section.indexOf('Removed')  >= 0 ||
                    section.indexOf('BS')       == 0 ||
                    section.indexOf('Advisory') == 0 ||
                    section.indexOf('paard') > -1) {
                    // Skip Unsure, Unlisted, BS, PAARD, etc.
                    continue;
                } else if (section.indexOf('Past') > -1) {
                    html
                    = html
                    + '<h2>Past Postdocs and Visiting Scientists</h2>'
                    + '<ul class="peopleCustom">'
                    + make_past_html_list(sh[section])
                    + '</ul>';
                } else if (section.indexOf('Alumni') > -1) {
                    html
                    = html
                    + '<h2>Student Alumni</h2>'
                    + '<ul class="peopleCustom">'
                    + make_alumni_html_list(sh[section])
                    + '</ul>';
                } else if (section.indexOf('MS') == 0) {
                    html
                    = html
                    + '<h2>'
                    + 'M.S. Students'
                    + '<span class="sort_method">Sort by '
                    + '<a class="scripted_link" id="mf">first name</a> '
                    + '<a class="scripted_link" id="ml">last name</a> '
                    + '<a class="scripted_link" id="ma">affiliation</a> '
                    + '<a class="scripted_link" id="mp">advisor</a>'
                    + '</h2>'
                    + '<ul id="ms_students" class="peopleNoPicture">'
                    + '</ul>';
                } else if (section.indexOf('PhD') == 0) {
                    html
                    = html
                    + '<h2>'
                    + 'Ph.D. Students<a id="#phd-students"></a>'
                    + '<span class="sort_method">Sort by '
                    + '<a class="scripted_link" id="pf">first name</a> '
                    + '<a class="scripted_link" id="pl">last name</a> '
                    + '<a class="scripted_link" id="pa">affiliation</a> '
                    + '<a class="scripted_link" id="pp">advisor</a>'
                    + '</h2>'
                    + '<ul id="phd_students" class="peopleNoPicture">'
                    + '</ul>';
                } else {
                    if (section.indexOf('Postdocs') > -1) {
                        html += '<h2>Postdoctoral Fellows and Visiting Scientists</h2>';
                    } else if (section.indexOf('Affiliates') > -1) {
                        html += '<h2>Affiliate Members and Emeritus Faculty</h2>';
                    } else if (section.indexOf('Advisory') > -1) {
                        html += '<h2>Advisory Board Members</h2>';
                    } else {
                        html += '<h2>' + section + '</h2>';
                    }
                    html += '<ul class="people">' + people_cells(sh[section]) + '</ul>';
                }
            }
            document.getElementById('main_body').innerHTML = html;
            phd_students = sh['PhD Students'];
            $('#pf').click(function() {insert_students(0, sort_firstname);});
            $('#pl').click(function() {insert_students(0, sort_lastname);});
            $('#pa').click(function() {insert_students(0, sort_affil);});
            $('#pp').click(function() {insert_students(0, sort_advisor);});
            insert_students(0, sort_lastname);
            ms_students = sh['MS Students'];
            $('#mf').click(function() {insert_students(1, sort_firstname);});
            $('#ml').click(function() {insert_students(1, sort_lastname);});
            $('#ma').click(function() {insert_students(1, sort_affil);});
            $('#mp').click(function() {insert_students(1, sort_advisor);});
            insert_students(1, sort_lastname);
        }
        var handle_error = function() {
            document.getElementById('main_body').innerHTML = 'Retrieval failed.';
        }
        req.open('GET', 'php/people.php', true);
        req.addEventListener('load', handle_complete, false);
        req.addEventListener('error', handle_error, false);
        req.send(null);
    } else {
        document.getElementById('main_page').innerHTML = 'XHR Not Available.';
    }
}


// Retrieve the data from a spreadsheet when the page is ready
$(document).ready(function() {
                  
                  populate_people();
                  
                  // Click or scroll to dismiss the pop-up card
                  $(document).click(function(event) {
                                    var elem_class = 'undefined';
                                    var parents = $(event.target).parents();
                                    if (parents instanceof Array) {
                                    elem_class = parents[0].className;
                                    if (elem_class == 'undefined')
                                    return;
                                    if (elem_class != "peopleNoPicture" && elem_class != "student_entry") {
                                    document.getElementById('name_card').style.opacity = '0.0';
                                    setTimeout('hide_popup()', 500);
                                    }
                                    }
                                    //document.getElementById('debug').innerHTML = 'Clicked ' + $(event.target).parents()[0].className;
                                    });
                  
                  $(document).scroll(function(event) {
                                     document.getElementById('name_card').style.opacity = '0.0';
                                     setTimeout('hide_popup()', 500);
                                     });
                  })
