#if SHADOW_FILTER_SAMPLES == 4
vec2 shadowFilterSamples[4] = vec2[4](
	vec2(0.3535533905932738, 0.0),
	vec2(-0.4515442403381579, 0.4136517847386082),
	vec2(0.06911558795753697, -0.7875424023513172),
	vec2(0.5691431693550262, 0.7423449688497363)
);
#elif SHADOW_FILTER_SAMPLES == 8
vec2 shadowFilterSamples[8] = vec2[8](
	vec2(0.25, 0.0),
	vec2(-0.3192899943488396, 0.29249598203858784),
	vec2(0.048872100930469675, -0.5568765731745609),
	vec2(0.4024449945169426, 0.5249171614533649),
	vec2(-0.7385352852030814, -0.13063549483200582),
	vec2(0.6996044150551861, -0.44503220381820774),
	vec2(-0.23400244682887578, 0.8704842645781135),
	vec2(-0.4462736882777369, -0.8592670103937339)
);
#elif SHADOW_FILTER_SAMPLES == 16
vec2 shadowFilterSamples[16] = vec2[16](
	vec2(0.1767766952966369, 0.0),
	vec2(-0.22577212016907894, 0.2068258923693041),
	vec2(0.034557793978768486, -0.3937712011756586),
	vec2(0.2845715846775131, 0.37117248442486817),
	vec2(-0.5222233083126399, -0.0923732442593715),
	vec2(0.4946950260335701, -0.31468528916624844),
	vec2(-0.1654647169669426, 0.6155253263993689),
	vec2(-0.31556315124631923, -0.6075935298993009),
	vec2(0.6846428169796912, 0.25002842470029907),
	vec2(-0.712255359408357, 0.294010719182264),
	vec2(0.3433527943507568, -0.7337294178452483),
	vec2(0.2537335422352867, 0.8089309547450474),
	vec2(-0.7647476345320706, -0.4431828691156761),
	vec2(0.8971332374879372, -0.19723578325043495),
	vec2(-0.5475025897403291, 0.7787752655468926),
	vec2(-0.126492035732319, -0.976089014842547)
);
#elif SHADOW_FILTER_SAMPLES == 32
vec2 shadowFilterSamples[32] = vec2[32](
	vec2(0.125, 0.0),
	vec2(-0.1596449971744198, 0.14624799101929392),
	vec2(0.024436050465234838, -0.2784382865872804),
	vec2(0.2012224972584713, 0.26245858072668243),
	vec2(-0.3692676426015407, -0.06531774741600291),
	vec2(0.34980220752759306, -0.22251610190910387),
	vec2(-0.11700122341443789, 0.4352421322890567),
	vec2(-0.22313684413886845, -0.42963350519686694),
	vec2(0.484115578577, 0.17679679459497155),
	vec2(-0.5036405945741108, 0.20789697327531262),
	vec2(0.2427870892247702, -0.5188250469144329),
	vec2(0.1794167083290545, 0.5720005636119312),
	vec2(-0.5407582382739986, -0.3133776120574047),
	vec2(0.6343689958555617, -0.13946675982902262),
	vec2(-0.38714279392258294, 0.5506772712885619),
	vec2(-0.08944337623241383, -0.6901991614368616),
	vec2(0.5490741831533417, 0.4627553796494327),
	vec2(-0.7388783156721436, 0.03055870791601175),
	vec2(0.538952473472529, -0.5363349991729449),
	vec2(-0.036054446813613895, 0.7797916881225166),
	vec2(-0.5128203868969519, -0.6145244102416605),
	vec2(0.8123605018333064, 0.1092950825112389),
	vec2(-0.688306731543945, 0.47891423377395204),
	vec2(0.18807935797523018, -0.8360628894429085),
	vec2(0.43503923573017034, 0.7591876338398229),
	vec2(-0.8504505034275064, -0.27130967771146836),
	vec2(0.8260995135102631, -0.38168651243934015),
	vec2(-0.35787859745188405, 0.8551595812980594),
	vec2(-0.31941717529174146, -0.8880302180267542),
	vec2(0.8499135188254747, 0.446678867328307),
	vec2(-0.9440319627700989, 0.2488546830349681),
	vec2(0.5365869335936416, -0.8345354771946922)
);
#elif SHADOW_FILTER_SAMPLES == 64
vec2 shadowFilterSamples[64] = vec2[64](
	vec2(0.08838834764831845, 0.0),
	vec2(-0.11288606008453947, 0.10341294618465205),
	vec2(0.017278896989384243, -0.1968856005878293),
	vec2(0.14228579233875654, 0.18558624221243408),
	vec2(-0.26111165415631993, -0.04618662212968575),
	vec2(0.24734751301678504, -0.15734264458312422),
	vec2(-0.0827323584834713, 0.3077626631996844),
	vec2(-0.15778157562315961, -0.30379676494965047),
	vec2(0.3423214084898456, 0.12501421235014953),
	vec2(-0.3561276797041785, 0.147005359591132),
	vec2(0.1716763971753784, -0.3668647089226241),
	vec2(0.12686677111764336, 0.4044654773725237),
	vec2(-0.3823738172660353, -0.22159143455783806),
	vec2(0.4485666187439686, -0.09861789162521747),
	vec2(-0.27375129487016453, 0.3893876327734463),
	vec2(-0.0632460178661595, -0.4880445074212735),
	vec2(0.3882540782821923, 0.32721746698066917),
	vec2(-0.5224658674834672, 0.021608269591710937),
	vec2(0.38109694872968813, -0.37924611490287075),
	vec2(-0.025494343833836097, 0.551395990584337),
	vec2(-0.36261877310554363, -0.434534377686542),
	vec2(0.5744256196144377, 0.07728329399404027),
	vec2(-0.48670635741107204, 0.338643502308321),
	vec2(0.13299218942549743, -0.5911857386234994),
	vec2(0.30761919366701646, 0.5368267240811085),
	vec2(-0.601359318037103, -0.19184491291131597),
	vec2(0.5841405679380149, -0.26989312123330095),
	vec2(-0.2530583830997579, 0.6046891389325065),
	vec2(-0.22586205067624257, -0.6279321890652863),
	vec2(0.6009796125836137, 0.3158496561005721),
	vec2(-0.6675314025315834, 0.17596683390405485),
	vec2(0.3794242594401597, -0.5901056950651182),
	vec2(0.12070645725357194, 0.7023122177331756),
	vec2(-0.5720123865279759, -0.44298908525895925),
	vec2(0.7317013125193749, -0.06062746289779906),
	vec2(-0.5057547837208649, 0.5467171103445191),
	vec2(0.0036765604199011713, -0.7551814238336897),
	vec2(0.5143104668173364, 0.5669411289738411),
	vec2(-0.7722955522342918, -0.07156870823991611),
	vec2(0.6257828238637205, -0.4749561636163361),
	vec2(-0.14237329637408702, 0.7826508445530334),
	vec2(-0.42889537161039915, -0.6815322884582782),
	vec2(0.7859237132651337, 0.21537506106219456),
	vec2(-0.7334793202861358, 0.3764247424287997),
	vec2(0.2898489128797462, -0.7818568332517337),
	vec2(0.3179241007722363, 0.7809364674211117),
	vec2(-0.7702697732500832, -0.36503010343979214),
	vec2(0.8232592714880846, -0.25383394554099364),
	vec2(-0.4401447179504025, 0.7510560080715424),
	vec2(-0.18465663527102075, -0.8598484907531008),
	vec2(0.7241852931140914, 0.5144104987626688),
	vec2(-0.8901556658679926, 0.11095219927117587),
	vec2(0.5870438263267859, -0.6897043177852423),
	vec2(0.0333335883221277, 0.9136883341104727),
	vec2(-0.6477417206085012, -0.657261868194967),
	vec2(0.9300151917248994, 0.047531496514400313),
	vec2(-0.7243098490915778, 0.5984878800017055),
	vec2(0.1309546561449395, -0.9387696086015784),
	vec2(0.5422221079426416, 0.7874374169787961),
	vec2(-0.9396537169400503, -0.21619063865197247),
	vec2(0.8459264136568891, -0.4792921892516023),
	vec2(-0.3024719264730592, 0.9324420806118074),
	vec2(-0.41011621679842475, -0.8990924250147742),
	vec2(0.916984083568314, 0.3890085994966943)
);
#endif