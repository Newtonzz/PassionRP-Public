var openedApp = ".main-screen"
var steps = "233.5k"
var currentapp 
fxFitbit = {}

$(document).ready(function(){

    // var elem = document.querySelector('.js-switch');
    // var init = new Switchery(elem);

    var circleProgress1 = new CircleProgress(".hunger-progress");
    circleProgress1.max = 100;
    circleProgress1.value = 0;
    circleProgress1.textFormat = "none"

    var circleProgress2 = new CircleProgress(".thirst-progress");
    circleProgress2.max = 100;
    circleProgress2.value = 0;
    circleProgress2.textFormat = "none"


    var circleProgress3 = new CircleProgress(".stress-progress");
    circleProgress3.max = 100;
    circleProgress3.value = 0;
    circleProgress3.textFormat = "none"
    console.log('Loaded Fitbit..')

    window.addEventListener('message', function(event){
        var eventData = event.data;

        if (eventData.action == "openWatch") {
            $('.circle-text span').text(kFormatter(eventData.stepData));
            document.getElementById("compassCheckBox").checked = eventData.compassToggle;
            document.getElementById("togglehudCheckBox").checked = eventData.hudToggle;
            document.getElementById("toggleHungerThirstCheckBox").checked = eventData.hungerThirstToggle;
            document.getElementById("food-input").placeholder = eventData.foodReminder+"%";
            document.getElementById("thirst-input").placeholder = eventData.thirstReminder+"%";
            circleProgress1.value = eventData.hungerData;
            circleProgress2.value = eventData.thirstData;
            circleProgress3.value = eventData.stressData;


            fxFitbit.Open();
        }
        if (eventData.action == "passiveUpdate") {
            steps = kFormatter(eventData.stepData);
            $('.circle-text span').text(steps);
            document.getElementById("compassCheckBox").checked = eventData.compassToggle;
            document.getElementById("togglehudCheckBox").checked = eventData.hudToggle;
            document.getElementById("toggleHungerThirstCheckBox").checked = eventData.hungerThirstToggle;
            document.getElementById("food-input").placeholder = eventData.foodReminder+"%";
            document.getElementById("thirst-input").placeholder = eventData.thirstReminder+"%";
            circleProgress1.value = eventData.hungerData;
            circleProgress2.value = eventData.thirstData;
            circleProgress3.value = eventData.stressData;
        }
    });
});

$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27:
            fxFitbit.Close();
            break;
    }
});

$(document).on('keydown', function(data) {
    if(data.which == 78) {
      $.post("http://krovi-voip/talkOn", JSON.stringify({}));
    }
});

$(document).on("keyup", function(data) {
    if(data.which == 78) {
      $.post("http://krovi-voip/talkOff", JSON.stringify({}));
    }
});

fxFitbit.Open = function() {
    $(".container").fadeIn(150);
}

fxFitbit.Close = function() {
    $(".container").fadeOut(150);
    $(openedApp).css({"display":"none"});
    $(".main-screen").css({"display":"block"});
    openedApp = ".main-screen";
    $.post('http://prp-fitbit/close')
}

function kFormatter(num) {
    return Math.abs(num) > 999 ? Math.sign(num)*((Math.abs(num)/1000).toFixed(1)) + 'k' : Math.sign(num)*Math.abs(num)
}

$(document).on('click', '.fitbit-app', function(e){
    e.preventDefault();

    currentapp = $(this).data('app');
    $(openedApp).css({"display":"none"});
    $(currentapp).css({"display":"block"});
    if (currentapp === "step-app") {
        $('.circle-text span').text(steps);
    };

    openedApp = currentapp;
}); 

$(document).on('click', '.fitbit-settings-app', function(e){
    e.preventDefault();
    currentapp = $(this).data('app');
    if (openedApp == "settings") {
        $(".settings-app").css({"display":"none"});
    }else {
        $(openedApp).css({"display":"none"});
    }
    $(openedApp).css({"display":"none"});
    $(currentapp).css({"display":"block"});

    openedApp = currentapp;
}); 

$(document).on('click', '.app-button', function(e){
    e.preventDefault();
    currentapp = $(this).data('app');
    if (this.classList[1] == "back") {
        $(openedApp).css({"display":"none"});
        $(".main-screen").css({"display":"block"});
        openedApp = ".main-screen";
    } else if (this.classList[1] == "back-settings") {
        $(openedApp).css({"display":"none"});
        $(".settings-app").css({"display":"block"});
        openedApp = ".settings-app";
    }else if (this.classList[1] == "settings-app-back-button") {
        $(".settings-app").css({"display":"none"})
        $(".main-screen").css({"display":"block"});
        openedApp = ".main-screen";
    }
});

function compassToggle() {
    var checkBox = document.getElementById("compassCheckBox").checked
    $.post('http://prp-fitbit/toggleCompass',JSON.stringify({
        value: checkBox
    }))
}

function togglehudToggle() {
    var checkBox = document.getElementById("togglehudCheckBox").checked
    $.post('http://prp-fitbit/toggleHud',JSON.stringify({
        value: checkBox
    }))
}

function toggleHungerThirstToggle() {
    var checkBox = document.getElementById("toggleHungerThirstCheckBox").checked;
    $.post('http://prp-fitbit/toggleHungerThirst', JSON.stringify({ value: checkBox }));
}



$(document).on('click', '.save-food-settings', function(e){
    e.preventDefault();

    var foodValue = $(this).parent().parent().find('input');

    if (parseInt(foodValue.val()) <= 100) {
        $.post('http://prp-fitbit/setFoodWarning', JSON.stringify({
            value: foodValue.val()
        }));
    }
});

$(document).on('click', '.save-thirst-settings', function(e){
    e.preventDefault();

    var thirstValue = $(this).parent().parent().find('input');

    if (parseInt(thirstValue.val()) <= 100) {
        $.post('http://prp-fitbit/setThirstWarning', JSON.stringify({
            value: thirstValue.val()
        }));
    }
});

$(document).on('click', '.reset-steps', function(e){
    e.preventDefault();

    steps = 0
    $('.circle-text span').text(steps);
    $.post('http://prp-fitbit/setStepCount', JSON.stringify({
        value: steps
    }));
});





    $(document).ready(function(){ 
        var endTime = "";
        var left = 0;
        var timerState = 0;
        var prevState = 0;
        var stateExchange = 0;
        var idArr = ["", "#break-tag", "#min-tag"];
        var wholeThing = "";
        var oldInterval = "";
        var onSound = new Audio("http://rcptones.com/dev_tones/tones/beep_short_on.wav");
        var offSound = new Audio("http://rcptones.com/dev_tones/tones/beep_short_off.wav");
        onSound.volume = 0.2; 
        offSound.volume = 0.2; 
        
        function alarm(){
            $("#timer").addClass("alarm");
            setTimeout(function(){$("#timer").removeClass("alarm")}, 2000);
        };
        
        function calcTime(){
            
            var nowTime = new Date();
            var diff = Math.round((endTime - nowTime.getTime())/1000);
            var mins = Math.floor(diff/60);
            var secs = diff%60;
            if (secs<10){secs = "0" + secs.toString()}
            var display = mins.toString() + ":" + secs;
            $("#time").text(display);
            $("#state").text("In Session");
        
            if (diff<0) {
            clearInterval(wholeThing);
            stateExchange = prevState;
            prevState= timerState;
            timerState = stateExchange;
            var setValue = $(idArr[timerState]).text()*1000*60;
            var startTime = new Date();
            endTime = startTime.getTime()  + setValue;
            offSound.play();
            alarm();
            breakTime();
            wholeThing = setInterval(breakTime, 1000);
            }   
        };
        
        function breakTime(){
            
            var nowTime = new Date();
            var diff = Math.round((endTime - nowTime.getTime())/1000);
            var mins = Math.floor(diff/60);
            var secs = diff%60;
            if (secs<10){secs = "0" + secs.toString()}
            var display = mins.toString() + ":" + secs;
            $("#time").text(display);
            $("#state").text("On Break");
        
            if (diff<0) {
            clearInterval(wholeThing);
            stateExchange = prevState;
            prevState= timerState;
            timerState = stateExchange;
            var setValue = $(idArr[timerState]).text()*1000*60;
            var startTime = new Date();
            endTime = startTime.getTime()  + setValue;
            //onSound.play();
            alarm();
            calcTime();
            wholeThing = setInterval(calcTime, 1000);
            }   
        };
        // amount of
        $("z").click(function(){
        
            if (timerState == 0 || timerState == 3) {
            var number = "";
            
            switch($(this).attr("id")) {
            
                case "min-less":
                number = +$("#min-tag").text();
                if (number>=2){
                    number -= 1;
                    $("#min-tag").text(number);
                }
                break;
        
                case "min-plus":
                number = +$("#min-tag").text() + 1;
                $("#min-tag").text(number);
        
            }
            }
        });
        
    $("#timer").click(function(){

        if (timerState < 1){
            //onSound.play();
            prevState = 1;
            timerState = 2;
            var setValue = $(idArr[timerState]).text()*1000*60;
            var startTime = new Date();
            endTime = startTime.getTime()  + setValue;
            alarm();
            calcTime();
            wholeThing = setInterval(calcTime, 1000);
        }
        else if (timerState >= 1 & timerState < 3){
            var nowTime = new Date();
            left = endTime - nowTime.getTime();
            oldInterval = $(idArr[timerState]).text()*1000*60;
            stateExchange = timerState;
            timerState = 3;
            clearInterval(wholeThing);
            $("#state").text("Paused");
        }
        
        else if (timerState == 3){
            var newInterval = $(idArr[stateExchange]).text()*1000*60;
            
            if (oldInterval == newInterval) {
            
            var nowTime = new Date();
            endTime = left + nowTime.getTime();
            timerState = stateExchange;
    
            if (timerState == 1){
                breakTime();
                wholeThing = setInterval(breakTime, 1000);
            }
    
            else if (timerState == 2){
                calcTime();
                wholeThing = setInterval(calcTime, 1000);
            }
            }
            
            else if (oldInterval != newInterval) {
            
            var nowTime = new Date();
            endTime = newInterval + nowTime.getTime();
            timerState = stateExchange;
    
            if (timerState == 1){
                offSound.play();
                alarm();
                breakTime();
                wholeThing = setInterval(breakTime, 1000);
            }
    
            else if (timerState == 2){
                //onSound.play();
                alarm();
                calcTime();
                wholeThing = setInterval(calcTime, 1000);
            }
            }
            
            
        }
        
        });
    })