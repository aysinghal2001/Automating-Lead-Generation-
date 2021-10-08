import "commonReactions/all.dsl";

/**
Initialize the variables. Named Entities are stored as data arrays which is why we are initializing the variables as data arrays. 
*/

context 
{
    input phone: string;
    input name: string = "";

    output software: string = "";
    output invoices: string = "";
    output lead_source: string = "";
    calltime: string = "";
    callday: string = "";
    output calltimeday: string ="";
    callback: string = "";
    
    visitedNodeTime: boolean = false;
    visitedNodeQuestion1: boolean = false;
}

start node root {
    do {
        #connectSafe($phone);
        wait *;
    }
    transitions {
        hello: goto hello on true;        
    }
}

node hello
{
    do
    {
        #sayText("Hi " + $name + " this is Dasha with ACME. Thank you so much for reaching out to us on our website.");
        #sayText("Is it okay if I ask you a few questions?");
        wait*;
    }
    transitions
    {
        question_1: goto question_1 on #messageHasIntent("yes");
        call_back: goto call_back on #messageHasIntent("no");
    }
}

node question_1
{
    do 
    {
        if ($visitedNodeQuestion1==false) 
        #sayText("Great! Are you using any invoicing software already?");
        else #sayText("Going back to the question 1. Are you using any invoicing software already?"); 
        set $visitedNodeQuestion1=true;
        wait *;
    }
    transitions
    {
        question_1_a: goto question_1_a on #messageHasIntent("yes");
        question_2: goto question_2 on #messageHasIntent("no");
    }
}

node question_1_a
{
    do 
    {
        #sayText("Great and what software are you using?");
        wait *;
    }
    transitions 
    {
       question_2: goto question_2 on #messageHasData("software");
    }
    onexit
    {
        question_2: do 
        {
        set $software = #messageGetData("software", { value: true })[0]?.value??"";
        }
    }
}

node question_2
{
    do 
    {
        set $software = "not using any invoicing software now";
        #sayText("Thank you for that. Question 2. How many invoices per month do you generally issue?");
        wait *;
    }
    transitions 
    {
       question_3: goto question_3 on #messageHasData("numberword");
    }
    onexit
    {
        question_3: do 
        {
        set $invoices = #messageGetData("numberword", { value: true })[0]?.value??"";
        }
    }
}

node question_3
{
    do 
    {
        #sayText("Thank you. And final question. How did you find out about us?");
        wait *;
    }
    transitions 
    {
       time: goto time on #messageHasData("channel");
    }
    onexit
    {
        time: do 
        {
        set $lead_source = #messageGetData("channel", { value: true })[0]?.value??"";
        }
    }
}


node time
{
    do 
    {
        if ($visitedNodeTime == false) 
        #sayText("Great, thank you for your replies. Now, let's find a time to meet. When are you available for a 30 minute call this week?"); 
        else #sayText("Let's try this again. What time can you meet with the A. E. this week?"); 
        set $visitedNodeTime=true;
        wait *;
    }
    transitions 
    {
       time_confirm: goto time_confirm on #messageHasData("callday");
    }
    onexit
    {
        time_confirm: do 
    {
        set $callday = #messageGetData("callday", { value: true })[0]?.value??"";
        set $calltime = #messageGetData("numberword", { value: true })[0]?.value??"";
    }
    }
}

node time_confirm
{
    do
    {
        #sayText("Perfect. Let's confirm, you can take a call on " + $callday + " at " + $calltime + " is that right?");
        set $calltimeday = $callday + " " + $calltime;
        wait *;
    }
     transitions 
    {
        correct: goto success on #messageHasIntent("yes");
        incorrect: goto time on #messageHasIntent("no");
    }
}

node success
{
    do 
    {
        #sayText("Perfect. You will have an invite later today. Thank you so much! We'll speak soon! Bye!");
        exit;
    }
}

/**
Perfect world conversation flow ends

Can't talk now flow begins
*/


node call_back
{
    do 
    {
        #sayText("No worries, when may we call you back?");
        wait *;
    }
    transitions 
    {
       callback_confirm: goto callback_confirm on #messageHasData("callback");
    }
    onexit
    {
        callback_confirm: 
        do 
        {
        set $callback = #messageGetData("callback", { value: true })[0]?.value??"";
        }
    }
}

node callback_confirm
{ 
    do 
    { 
        #sayText("Perfect. we'll call you back " + $callback + " Thanks for your time. Bye!");
        exit;
    }
}

/**
Can't talk now flow ends
Digressions begin
*/

digression can_help
{
     conditions {on #messageHasIntent("can_help");}
    do
    {
        #sayText("How can I help?");
        wait *;
    }
}

digression connect_me 
{
    conditions {on #messageHasIntent("connect_me");}
    do 
    {
        #sayText("Certainly. Please hold, I will now transfer you. Good bye!");
        #forward("79231017918");
    }
}

digression how_do 
{
    conditions {on #messageHasIntent("how_do");}
    do 
    {
        #sayText("I'm well, thank you!", repeatMode: "ignore");
        #repeat();
        return;
    }

}

digression transfer_me 
{
    conditions {on #messageHasIntent("transfer_me");}
    do 
    {
        #sayText("Certainly. Please hold, I will transfer you to an account executive right away. Good bye!");
        #forward("12223334455");
    }
}

digression bye 
{
    conditions { on #messageHasIntent("bye"); }
    do 
    {
        #sayText("Thank you for your time. Have a great day. Bye!");
        exit;
    }
}

/**
Digressions end
*/
