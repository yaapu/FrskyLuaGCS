LuaR  

         %      K   @ Ë   À @ Á À @ÁÀ  @ AB   ÁÀ ¥  J¥A  å  %Â  e ¥B å %Ã e ¥C å %Ä e ¥D ËÄ  ÊÊÊDß              	   messages    messageCount 
   msgBuffer        lastMsgValue    lastMessageCount    /MODELS/yaapu/    /SCRIPTS/TOOLS/yaapu/    LCD_W      j@   /SCRIPTS/YAAPU/CFG/    clearTable    run    init    compileAll              F @    ] @À F@    ]  @ À @@ ÁÀ ÀA 
 Ab  ã ý   F@A ]@ F@A ]@ A I          type    table    pairs    clearTable     collectgarbage                                      ¯    H   @    @ À    À@  AÀ   A A   @     @ @  À   ÀÀ@  AÀ   A AÁ  @         ÀÀ@  AÀ   A A  @     @B @ @B @    ÆÂ À ÆÀ@ ÇÀÂ FAÃ Â À Ý ÆÀ@ ÇÀÂ FAÃ  Ý  Æ@B Ý@ Æ@B Ý@           LCD_W      j@      I@   string    sub       ð?      `@      C@      8@   collectgarbage    lastMessageCount    format    %02d:(x%d) %s    messageCount    %02d:%s                          ±   ½       F @ @  À F@@ MÀ @À ÀFÀ@ MÀ @F A À@ @@AÅ     Ý JÀ   FA]@ FA]@         lastMessage    lastMessageCount       ð?   messageCount 	   messages       "@   collectgarbage                          ¿   Ê     
6    @   @ À@ F A @ @ FÀÁ U    ! @ ABA Á ÆÁÁ Ã Â FÂÁ UMÂBÇBC FA BA @û  FÀÁ U    !@ ABA Á ÆÁÁ Ã Â FÂÁ UMÂBÇBC A Àû        LCD_W      j@   lcd 	   setColor    CUSTOM_COLOR     àÿï@        	   messages       ð?	   drawText       *@       @   messageCount    SMLSIZE       @                         Ì   Ï         @ @@  F@ GÀÀ @  AÇ@A  AÁ   ^   _           model    getInfo    string    lower    gsub    name    [%c%p%s%z]                              Ñ   Ó           E  ] @                 	                Õ   ó    m   F @ @@ @Å  Ý Á  @   ÖA  ]  XÁ À @@ ÀAÀ  @  @ Æ@@ ÇÀ A   Á ÁAA Ý   @  XÁ À @@ ÀAÀ  @  @ Æ@@ ÇÀ AA   Á ÁAA Ý   @  XÁ À @@ ÀAÀ  @  @ Æ@@ ÇÀ A   Á ÁAA Ý   @  XÁ À @@ ÀAÀ  @  @ Æ@@ ÇÀ AÁ   Á ÁAA Ý   @  XÁ À @@ ÀAÀ  @  @ Æ@@ ÇÀ A   Á ÁAA Ý   @  XÁ À @@ ÀAÀ  @         assert    io    open    _    _1.lua    a+     close    qplane_    plane_    copter_    heli_    rover_          
                ö   ý       F @ G@À   Á  À À   ]À@ À   Æ A  Ý@ Æ@A Ý@ Æ@A Ý@ Å @ A@A   Ý@          string    format    default_%s.lua    loadScript    clearTable    collectgarbage    GLOBAL: default_%s.lua                          ÿ       )    A   @  Á  Á  A $@A@    Á@ aÀFA GÁÁ Á ÁÇ ]AB À ÆB  ÝA ÆÁB ÝA ÆÁB ÝA ÅA ÂAA  ÝA  `ùFÀB ]@ FÀB ]@         plane    qplane    copter    rover    heli       ð?   string    format    %s_tune.lua    loadScript    clearTable    collectgarbage    TUNE: %s_tune.lua                            #   >   K    Á@    AÁ   d@@ Õ  A ¡ A @
ÆÁA ÇÂ AB BGB   À ÝB ÂB@ X@C@FB GÃ ]B FD ] @FBDÂC ]B FD ]B FD ]B EÂA BÁÂ C @   ]B  AAÀô @ôD @ D @         plane    qplane    copter    rover    heli       ð?           string    format    %s_%s_%d.lua    io    open    r     close    tmp    loadScript    clearTable    collectgarbage    FRAME: %s_%s_%d.lua                          &  9   	/   A   @
À@  AÁ@   @    A ÀAÆ@  X@BÆA ÇÂ  Ý@ Æ C @ Ý ÀÆ@CÁB Ý@ ÆC Ý@ ÆC Ý@ Å Á@ AAÁ   À    Ý@  M À ô           ð?           page    string    format    %s_%s_%d.lua    io    open    r     close    tmp    loadScript    clearTable    collectgarbage    MODEL: %s_%s_%d.lua          
	                >  T   R   F @ @@F@ GÀÀ  A Á@ ]@F@ GÁ  A ]@  F@ GÁ ]@ E    ]@ F @ @ÀF@ GÀÀ  A Æ@ ÇÀÁ AA A Ý  ]@  FB GÀÂ  Æ C A Ý ÏÃ]I F@ GÀÃ  @ Æ D Î@ÄFD ÁD ME M]@ FB GÀÂ  Æ C A Ý ÏÃ]I F@ GÀÃ  @ Æ D Î@ÅFD E ME M]@F C ]@ F C ]@ A@ _          LCD_W      j@   lcd 	   setColor    CUSTOM_COLOR      b¥@   clear    RGB      ào@           math    max    collectgarbage    count       @   drawNumber    LCD_H       ,@   SMLSIZE    MENU_TITLE_COLOR    RIGHT       @   INVERS                           V  `          A   @    A@  @   @   A   @   A@  @  A   @  A@  @   A   @   A@  @         params 	   commands                        b  e          A   @   @         Yaapu LuaGCS 1.0                                            