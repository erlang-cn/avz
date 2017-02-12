-module(google).
-author('Andrii Zadorozhnii').
-include_lib("avz/include/avz.hrl").
-include_lib("nitro/include/nitro.hrl").
-include_lib("n2o/include/wf.hrl").
-include_lib("avz/include/avz_user.hrl").
-compile(export_all).
-export(?API).

-define(G_CLIENT_ID,     application:get_env(avz, g_client_id,    [])).
-define(G_COOKIE_POLICY, application:get_env(avz, g_cookiepolicy, [])).
-define(G_BTN_ID,        application:get_env(avz, g_btn_id, "gloginbtn")).
-define(G_BTN_HEIGHT,    application:get_env(avz, g_btn_height, 50)).
-define(G_BTN_WIDTH,     application:get_env(avz, g_btn_width, 240)).
-define(G_BTN_THEME,     application:get_env(avz, g_btn_theme, "light")).
-define(G_BTN_LONGTITLE, application:get_env(avz, g_btn_longtitle, true)).

api_event(gLogin, Args, _) -> {JSArgs} = ?AVZ_JSON:decode(list_to_binary(Args)), avz:login(google, JSArgs);
api_event(gLoginFail, Args, _) -> wf:info(?MODULE, "Login failed ~p~n", [Args]).

registration_data(Props, google, Ori)->
    Id = proplists:get_value(<<"Eea">>, Props),
    Name = proplists:get_value(<<"ig">>, Props),
    Image = proplists:get_value(<<"Paa">>, Props),
    GivenName = proplists:get_value(<<"ofa">>, Props),
    FamilyName = proplists:get_value(<<"wea">>, Props),
    Email = email_prop(Props,google),
    Ori#avz_user{id = Email,
                display_name = Name,
                images = avz:update({google_avatar,Image},Ori#avz_user.images),
                email = Email,
                names = GivenName,
                surnames = FamilyName,
                tokens = avz:update({google,Id},Ori#avz_user.tokens),
                register_date = os:timestamp(),
                % sex = proplists:get_value(<<"gender">>, Props),
                status = ok }.

email_prop(Props, _) -> proplists:get_value(<<"U3">>, Props).

login_button()-> #panel{id=?G_BTN_ID}.

event(_) -> ok.
callback() -> ok.
sdk() ->
    wf:wire(#api{name=gLogin, tag=plus}),
    wf:wire(#api{name=gLoginFail, tag=plus}),
    #dtl{bind_script=false, file="google_sdk", ext="dtl", folder="priv/static/js",
        bindings=[{loginbtnid, ?G_BTN_ID},
          {clientid,    ?G_CLIENT_ID},
          {cookiepolicy,?G_COOKIE_POLICY}, 
          {height,      ?G_BTN_HEIGHT},
          {width,       ?G_BTN_WIDTH},
          {theme,       ?G_BTN_THEME},
          {longtitle,   ?G_BTN_LONGTITLE} ]}.
