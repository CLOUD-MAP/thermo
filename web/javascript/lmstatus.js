function refresh_lmstatus() {
    debug = 0;
    d = new Date;
    document.title = "ARRC License Manager Status (Last updated " + d.toString("yyyy/MM/dd h:mm:ss") + ")";
    $.ajax({
           type: "GET",
           url: "php/lmstatus.php",
           async: true,
           cache: false,
           timeout: 10000,
           success: function(result) { process_php_result(result); },
           error: function(error) { console.log("Error in $.ajax [" + error + "]"); }
           });
}

function uptime(date_start) {
    var date_now = new Date();
    var period = (date_now.getTime() - date_start.getTime()) * 0.001;
    if (period > 0) {
        var days = parseInt(period / 86400);
        var hours = parseInt(period / 3600) % 24;
        var minutes = ("0" + parseInt(period / 60) % 60).slice(-2);
        var seconds = ("0" + parseInt(period) % 60).slice(-2);
        if (days) {
            return days + " days " + hours + " hours " + minutes + " minutes";
        } else if (hours) {
            return hours + " hours " + minutes + " minutes";
        } else if (minutes) {
            return minutes + " minutes";
        }
    } else {
        return "-";
    }
}

function tuple_compare(a, b) {
    if (a[1].used < b[1].used) {
        return 1;
    } else if (a[1].used > b[1].used) {
        return -1;
    } else if (a[0] < b[0]) {
        return -1;
    } else if (a[0] > b[1]) {
        return 1;
    } else {
        return 0;
    }
}

function list_users(software, name) {
    if (software == undefined) {
        html =  "<div class='software software_down'><span class='software_name'>" + name + " [ License Server Down ]</span>"
        var div = document.createElement("div");
        div.className = "lmstatus";
        div.innerHTML = html;
        return div
    }
    
    var max_width = document.getElementsByClassName("container")[0].offsetWidth;
    
    var width = software.used / software.total * 100;
    
    var bar_text = software.used + " / " + software.total;
    
    html =  "<div class='software'><span class='software_name'>" + name + "</span>"
    html += "<span class='bar_wrapper'><span class='bar' style='width:" + width + "%'></span><span class='bar_text'>" + bar_text + "</span></span>";
    html += "</div>";
    html += "<ul class='user_list'>";

    // Convert to a sortable array
    var tuples = [];
    var date_now = (new Date()).getTime();
    for (var key in software.users) {
        var user = software.users[key];
        var date_start = new Date(user.start);
        var period = (date_now - date_start.getTime()) * 0.001;
        var period_str = "-";
        if (period > 0) {
            var days = parseInt(period / 86400);
            var hours = parseInt(period / 3600) % 24;
            var minutes = ("0" + parseInt(period / 60) % 60).slice(-2);
            var seconds = ("0" + parseInt(period) % 60).slice(-2);
            if (days) {
                if (hours) {
                    period_str = days + " day" + (days > 1 ? "s " : " ") + hours + " hour" + (hours > 1 ? "s " : " ");
                } else {
                    period_str = days + " day" + (days > 1 ? "s " : " ") + minutes + " minute" + (minutes > 1 ? "s" : "");
                }
            } else if (hours) {
                period_str = hours + " hour" + (hours > 1 ? "s " : " ") + minutes + " minute" + (minutes > 1 ? "s" : "");
            } else if (minutes) {
                period_str = minutes + " minute" + (minutes > 1 ? "s" : "");
            }
        }
        tuples.push([key, user, period, period_str]);
    }

    // Sort the array accroding to CPU count, then name
    tuples.sort(tuple_compare);
    
    myvar = tuples;
    for (var i = 0; i < tuples.length; i++) {
        user = tuples[i];

        var date_start = new Date(user[1].start);
        var proc = user[1].used;

        var width = user[2] > 0 ? Math.min(100, 0.0002 * user[2]).toFixed(2) : 0;
        
        var bar_text = "";
        
        html += "<li class='user'>"
        html += "x" + proc + " <span class='username'>" + user[0] + "</span><span class='period'>" + user[3] +  "</span>";
        html += "<span class='bar_wrapper thin'><span class='bar' style='width:" + width + "%'></span><span class='bar_text'>" + bar_text + "</span></span>";
        html += "</li>";
    }
    html += "</ul>";
    var div = document.createElement("div");
    div.className = "lmstatus";
    div.innerHTML = html;
    return div
}

function process_php_result(result) {
    stat = JSON.parse(result);

    var o = document.getElementById("container_left");
    o.innerHTML = "";
    o.appendChild(list_users(stat.ansoftd.features.hfss_desktop, "HFSS Desktop"));
    o.appendChild(list_users(stat.ansoftd.features.hfss_solve, "HFSS Solver"));

    var o = document.getElementById("container_right");
    o.innerHTML = "";
    o.appendChild(list_users(stat.ansoftd.features.ansoft_distrib_engine, "ansoft_distrib_engine"));
    o.appendChild(list_users(stat.cstd.features.frontend, "cstd"));
    o.appendChild(list_users(stat.feko, "Feko"));
    o.appendChild(list_users(stat.feko_student, "Feko Student"));
    o.appendChild(list_users(stat.SW_D.features.solidworks, "SolidWorks"));
    o.appendChild(list_users(stat.SW_D.features.swofficepremium, "SolidWorks Office Premium"));
    o.appendChild(list_users(stat.xilinxd.features.Vivado_System_Edition, "Xilinx Vivado"));
    o.appendChild(list_users(stat.xilinxd.features.ISE, "Xilinx ISE"));
}

function setup() {
    var stat;
    var myvar;
    refresh_lmstatus();
    setInterval('refresh_lmstatus()', 60000);
    
    o = document.getElementsByClassName("header")[0];
    
    div = document.createElement("div");
    div.id = "fullscreenButton";
    div.onclick = function() { document.documentElement.webkitRequestFullscreen() };
    o.appendChild(div);
    
    div = document.createElement("div");
    div.id = "refreshButton";
    div.onclick = function(){ window.location.reload(); };
    o.appendChild(div);
}

$(document).ready(setup);
