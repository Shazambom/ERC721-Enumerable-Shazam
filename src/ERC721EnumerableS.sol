// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Enumerable.sol";


/**
 * Theory on how to implement this with less memory & thus less gas:
 * 
 * If we have a bitmap that represents all minted IDs we can iterate over the bit representation and the token space
 * Using this we can ensure that tokenID == index(in the bitmap) for our iteration
 * 
 * Abuse the fact that all functions in the interface are "view" functions and don't require gas to call.
 * This should significantly reduce the gas cost of this extension when minting or transfering an ERC-721 token
 */

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721EnumerableS is ERC721, IERC721Enumerable {

    //BitMap that represents each minted token in binary
    uint256[] private _bitmap;
    //Counter for each region of the bitmap, keeps track of the total number of active tokens in each region
    uint16[] private _counter;
    //Lookup Table for all individual bit locations in the bitmap spots [0...255], this allows for skipping over regions in the bitmap that aren't minted
    mapping(uint256 => uint16) public lookupTable;

    constructor() {
        lookupTable[uint256(0)] = 256;
        lookupTable[uint256(1)] = 0;
        lookupTable[uint256(2)] = 1;
        lookupTable[uint256(4)] = 2;
        lookupTable[uint256(8)] = 3;
        lookupTable[uint256(16)] = 4;
        lookupTable[uint256(32)] = 5;
        lookupTable[uint256(64)] = 6;
        lookupTable[uint256(128)] = 7;
        lookupTable[uint256(256)] = 8;
        lookupTable[uint256(512)] = 9;
        lookupTable[uint256(1024)] = 10;
        lookupTable[uint256(2048)] = 11;
        lookupTable[uint256(4096)] = 12;
        lookupTable[uint256(8192)] = 13;
        lookupTable[uint256(16384)] = 14;
        lookupTable[uint256(32768)] = 15;
        lookupTable[uint256(65536)] = 16;
        lookupTable[uint256(131072)] = 17;
        lookupTable[uint256(262144)] = 18;
        lookupTable[uint256(524288)] = 19;
        lookupTable[uint256(1048576)] = 20;
        lookupTable[uint256(2097152)] = 21;
        lookupTable[uint256(4194304)] = 22;
        lookupTable[uint256(8388608)] = 23;
        lookupTable[uint256(16777216)] = 24;
        lookupTable[uint256(33554432)] = 25;
        lookupTable[uint256(67108864)] = 26;
        lookupTable[uint256(134217728)] = 27;
        lookupTable[uint256(268435456)] = 28;
        lookupTable[uint256(536870912)] = 29;
        lookupTable[uint256(1073741824)] = 30;
        lookupTable[uint256(2147483648)] = 31;
        lookupTable[uint256(4294967296)] = 32;
        lookupTable[uint256(8589934592)] = 33;
        lookupTable[uint256(17179869184)] = 34;
        lookupTable[uint256(34359738368)] = 35;
        lookupTable[uint256(68719476736)] = 36;
        lookupTable[uint256(137438953472)] = 37;
        lookupTable[uint256(274877906944)] = 38;
        lookupTable[uint256(549755813888)] = 39;
        lookupTable[uint256(1099511627776)] = 40;
        lookupTable[uint256(2199023255552)] = 41;
        lookupTable[uint256(4398046511104)] = 42;
        lookupTable[uint256(8796093022208)] = 43;
        lookupTable[uint256(17592186044416)] = 44;
        lookupTable[uint256(35184372088832)] = 45;
        lookupTable[uint256(70368744177664)] = 46;
        lookupTable[uint256(140737488355328)] = 47;
        lookupTable[uint256(281474976710656)] = 48;
        lookupTable[uint256(562949953421312)] = 49;
        lookupTable[uint256(1125899906842624)] = 50;
        lookupTable[uint256(2251799813685248)] = 51;
        lookupTable[uint256(4503599627370496)] = 52;
        lookupTable[uint256(9007199254740992)] = 53;
        lookupTable[uint256(18014398509481984)] = 54;
        lookupTable[uint256(36028797018963968)] = 55;
        lookupTable[uint256(72057594037927936)] = 56;
        lookupTable[uint256(144115188075855872)] = 57;
        lookupTable[uint256(288230376151711744)] = 58;
        lookupTable[uint256(576460752303423488)] = 59;
        lookupTable[uint256(1152921504606846976)] = 60;
        lookupTable[uint256(2305843009213693952)] = 61;
        lookupTable[uint256(4611686018427387904)] = 62;
        lookupTable[uint256(9223372036854775808)] = 63;
        lookupTable[uint256(18446744073709551616)] = 64;
        lookupTable[uint256(36893488147419103232)] = 65;
        lookupTable[uint256(73786976294838206464)] = 66;
        lookupTable[uint256(147573952589676412928)] = 67;
        lookupTable[uint256(295147905179352825856)] = 68;
        lookupTable[uint256(590295810358705651712)] = 69;
        lookupTable[uint256(1180591620717411303424)] = 70;
        lookupTable[uint256(2361183241434822606848)] = 71;
        lookupTable[uint256(4722366482869645213696)] = 72;
        lookupTable[uint256(9444732965739290427392)] = 73;
        lookupTable[uint256(18889465931478580854784)] = 74;
        lookupTable[uint256(37778931862957161709568)] = 75;
        lookupTable[uint256(75557863725914323419136)] = 76;
        lookupTable[uint256(151115727451828646838272)] = 77;
        lookupTable[uint256(302231454903657293676544)] = 78;
        lookupTable[uint256(604462909807314587353088)] = 79;
        lookupTable[uint256(1208925819614629174706176)] = 80;
        lookupTable[uint256(2417851639229258349412352)] = 81;
        lookupTable[uint256(4835703278458516698824704)] = 82;
        lookupTable[uint256(9671406556917033397649408)] = 83;
        lookupTable[uint256(19342813113834066795298816)] = 84;
        lookupTable[uint256(38685626227668133590597632)] = 85;
        lookupTable[uint256(77371252455336267181195264)] = 86;
        lookupTable[uint256(154742504910672534362390528)] = 87;
        lookupTable[uint256(309485009821345068724781056)] = 88;
        lookupTable[uint256(618970019642690137449562112)] = 89;
        lookupTable[uint256(1237940039285380274899124224)] = 90;
        lookupTable[uint256(2475880078570760549798248448)] = 91;
        lookupTable[uint256(4951760157141521099596496896)] = 92;
        lookupTable[uint256(9903520314283042199192993792)] = 93;
        lookupTable[uint256(19807040628566084398385987584)] = 94;
        lookupTable[uint256(39614081257132168796771975168)] = 95;
        lookupTable[uint256(79228162514264337593543950336)] = 96;
        lookupTable[uint256(158456325028528675187087900672)] = 97;
        lookupTable[uint256(316912650057057350374175801344)] = 98;
        lookupTable[uint256(633825300114114700748351602688)] = 99;
        lookupTable[uint256(1267650600228229401496703205376)] = 100;
        lookupTable[uint256(2535301200456458802993406410752)] = 101;
        lookupTable[uint256(5070602400912917605986812821504)] = 102;
        lookupTable[uint256(10141204801825835211973625643008)] = 103;
        lookupTable[uint256(20282409603651670423947251286016)] = 104;
        lookupTable[uint256(40564819207303340847894502572032)] = 105;
        lookupTable[uint256(81129638414606681695789005144064)] = 106;
        lookupTable[uint256(162259276829213363391578010288128)] = 107;
        lookupTable[uint256(324518553658426726783156020576256)] = 108;
        lookupTable[uint256(649037107316853453566312041152512)] = 109;
        lookupTable[uint256(1298074214633706907132624082305024)] = 110;
        lookupTable[uint256(2596148429267413814265248164610048)] = 111;
        lookupTable[uint256(5192296858534827628530496329220096)] = 112;
        lookupTable[uint256(10384593717069655257060992658440192)] = 113;
        lookupTable[uint256(20769187434139310514121985316880384)] = 114;
        lookupTable[uint256(41538374868278621028243970633760768)] = 115;
        lookupTable[uint256(83076749736557242056487941267521536)] = 116;
        lookupTable[uint256(166153499473114484112975882535043072)] = 117;
        lookupTable[uint256(332306998946228968225951765070086144)] = 118;
        lookupTable[uint256(664613997892457936451903530140172288)] = 119;
        lookupTable[uint256(1329227995784915872903807060280344576)] = 120;
        lookupTable[uint256(2658455991569831745807614120560689152)] = 121;
        lookupTable[uint256(5316911983139663491615228241121378304)] = 122;
        lookupTable[uint256(10633823966279326983230456482242756608)] = 123;
        lookupTable[uint256(21267647932558653966460912964485513216)] = 124;
        lookupTable[uint256(42535295865117307932921825928971026432)] = 125;
        lookupTable[uint256(85070591730234615865843651857942052864)] = 126;
        lookupTable[uint256(170141183460469231731687303715884105728)] = 127;
        lookupTable[uint256(340282366920938463463374607431768211456)] = 128;
        lookupTable[uint256(680564733841876926926749214863536422912)] = 129;
        lookupTable[uint256(1361129467683753853853498429727072845824)] = 130;
        lookupTable[uint256(2722258935367507707706996859454145691648)] = 131;
        lookupTable[uint256(5444517870735015415413993718908291383296)] = 132;
        lookupTable[uint256(10889035741470030830827987437816582766592)] = 133;
        lookupTable[uint256(21778071482940061661655974875633165533184)] = 134;
        lookupTable[uint256(43556142965880123323311949751266331066368)] = 135;
        lookupTable[uint256(87112285931760246646623899502532662132736)] = 136;
        lookupTable[uint256(174224571863520493293247799005065324265472)] = 137;
        lookupTable[uint256(348449143727040986586495598010130648530944)] = 138;
        lookupTable[uint256(696898287454081973172991196020261297061888)] = 139;
        lookupTable[uint256(1393796574908163946345982392040522594123776)] = 140;
        lookupTable[uint256(2787593149816327892691964784081045188247552)] = 141;
        lookupTable[uint256(5575186299632655785383929568162090376495104)] = 142;
        lookupTable[uint256(11150372599265311570767859136324180752990208)] = 143;
        lookupTable[uint256(22300745198530623141535718272648361505980416)] = 144;
        lookupTable[uint256(44601490397061246283071436545296723011960832)] = 145;
        lookupTable[uint256(89202980794122492566142873090593446023921664)] = 146;
        lookupTable[uint256(178405961588244985132285746181186892047843328)] = 147;
        lookupTable[uint256(356811923176489970264571492362373784095686656)] = 148;
        lookupTable[uint256(713623846352979940529142984724747568191373312)] = 149;
        lookupTable[uint256(1427247692705959881058285969449495136382746624)] = 150;
        lookupTable[uint256(2854495385411919762116571938898990272765493248)] = 151;
        lookupTable[uint256(5708990770823839524233143877797980545530986496)] = 152;
        lookupTable[uint256(11417981541647679048466287755595961091061972992)] = 153;
        lookupTable[uint256(22835963083295358096932575511191922182123945984)] = 154;
        lookupTable[uint256(45671926166590716193865151022383844364247891968)] = 155;
        lookupTable[uint256(91343852333181432387730302044767688728495783936)] = 156;
        lookupTable[uint256(182687704666362864775460604089535377456991567872)] = 157;
        lookupTable[uint256(365375409332725729550921208179070754913983135744)] = 158;
        lookupTable[uint256(730750818665451459101842416358141509827966271488)] = 159;
        lookupTable[uint256(1461501637330902918203684832716283019655932542976)] = 160;
        lookupTable[uint256(2923003274661805836407369665432566039311865085952)] = 161;
        lookupTable[uint256(5846006549323611672814739330865132078623730171904)] = 162;
        lookupTable[uint256(11692013098647223345629478661730264157247460343808)] = 163;
        lookupTable[uint256(23384026197294446691258957323460528314494920687616)] = 164;
        lookupTable[uint256(46768052394588893382517914646921056628989841375232)] = 165;
        lookupTable[uint256(93536104789177786765035829293842113257979682750464)] = 166;
        lookupTable[uint256(187072209578355573530071658587684226515959365500928)] = 167;
        lookupTable[uint256(374144419156711147060143317175368453031918731001856)] = 168;
        lookupTable[uint256(748288838313422294120286634350736906063837462003712)] = 169;
        lookupTable[uint256(1496577676626844588240573268701473812127674924007424)] = 170;
        lookupTable[uint256(2993155353253689176481146537402947624255349848014848)] = 171;
        lookupTable[uint256(5986310706507378352962293074805895248510699696029696)] = 172;
        lookupTable[uint256(11972621413014756705924586149611790497021399392059392)] = 173;
        lookupTable[uint256(23945242826029513411849172299223580994042798784118784)] = 174;
        lookupTable[uint256(47890485652059026823698344598447161988085597568237568)] = 175;
        lookupTable[uint256(95780971304118053647396689196894323976171195136475136)] = 176;
        lookupTable[uint256(191561942608236107294793378393788647952342390272950272)] = 177;
        lookupTable[uint256(383123885216472214589586756787577295904684780545900544)] = 178;
        lookupTable[uint256(766247770432944429179173513575154591809369561091801088)] = 179;
        lookupTable[uint256(1532495540865888858358347027150309183618739122183602176)] = 180;
        lookupTable[uint256(3064991081731777716716694054300618367237478244367204352)] = 181;
        lookupTable[uint256(6129982163463555433433388108601236734474956488734408704)] = 182;
        lookupTable[uint256(12259964326927110866866776217202473468949912977468817408)] = 183;
        lookupTable[uint256(24519928653854221733733552434404946937899825954937634816)] = 184;
        lookupTable[uint256(49039857307708443467467104868809893875799651909875269632)] = 185;
        lookupTable[uint256(98079714615416886934934209737619787751599303819750539264)] = 186;
        lookupTable[uint256(196159429230833773869868419475239575503198607639501078528)] = 187;
        lookupTable[uint256(392318858461667547739736838950479151006397215279002157056)] = 188;
        lookupTable[uint256(784637716923335095479473677900958302012794430558004314112)] = 189;
        lookupTable[uint256(1569275433846670190958947355801916604025588861116008628224)] = 190;
        lookupTable[uint256(3138550867693340381917894711603833208051177722232017256448)] = 191;
        lookupTable[uint256(6277101735386680763835789423207666416102355444464034512896)] = 192;
        lookupTable[uint256(12554203470773361527671578846415332832204710888928069025792)] = 193;
        lookupTable[uint256(25108406941546723055343157692830665664409421777856138051584)] = 194;
        lookupTable[uint256(50216813883093446110686315385661331328818843555712276103168)] = 195;
        lookupTable[uint256(100433627766186892221372630771322662657637687111424552206336)] = 196;
        lookupTable[uint256(200867255532373784442745261542645325315275374222849104412672)] = 197;
        lookupTable[uint256(401734511064747568885490523085290650630550748445698208825344)] = 198;
        lookupTable[uint256(803469022129495137770981046170581301261101496891396417650688)] = 199;
        lookupTable[uint256(1606938044258990275541962092341162602522202993782792835301376)] = 200;
        lookupTable[uint256(3213876088517980551083924184682325205044405987565585670602752)] = 201;
        lookupTable[uint256(6427752177035961102167848369364650410088811975131171341205504)] = 202;
        lookupTable[uint256(12855504354071922204335696738729300820177623950262342682411008)] = 203;
        lookupTable[uint256(25711008708143844408671393477458601640355247900524685364822016)] = 204;
        lookupTable[uint256(51422017416287688817342786954917203280710495801049370729644032)] = 205;
        lookupTable[uint256(102844034832575377634685573909834406561420991602098741459288064)] = 206;
        lookupTable[uint256(205688069665150755269371147819668813122841983204197482918576128)] = 207;
        lookupTable[uint256(411376139330301510538742295639337626245683966408394965837152256)] = 208;
        lookupTable[uint256(822752278660603021077484591278675252491367932816789931674304512)] = 209;
        lookupTable[uint256(1645504557321206042154969182557350504982735865633579863348609024)] = 210;
        lookupTable[uint256(3291009114642412084309938365114701009965471731267159726697218048)] = 211;
        lookupTable[uint256(6582018229284824168619876730229402019930943462534319453394436096)] = 212;
        lookupTable[uint256(13164036458569648337239753460458804039861886925068638906788872192)] = 213;
        lookupTable[uint256(26328072917139296674479506920917608079723773850137277813577744384)] = 214;
        lookupTable[uint256(52656145834278593348959013841835216159447547700274555627155488768)] = 215;
        lookupTable[uint256(105312291668557186697918027683670432318895095400549111254310977536)] = 216;
        lookupTable[uint256(210624583337114373395836055367340864637790190801098222508621955072)] = 217;
        lookupTable[uint256(421249166674228746791672110734681729275580381602196445017243910144)] = 218;
        lookupTable[uint256(842498333348457493583344221469363458551160763204392890034487820288)] = 219;
        lookupTable[uint256(1684996666696914987166688442938726917102321526408785780068975640576)] = 220;
        lookupTable[uint256(3369993333393829974333376885877453834204643052817571560137951281152)] = 221;
        lookupTable[uint256(6739986666787659948666753771754907668409286105635143120275902562304)] = 222;
        lookupTable[uint256(13479973333575319897333507543509815336818572211270286240551805124608)] = 223;
        lookupTable[uint256(26959946667150639794667015087019630673637144422540572481103610249216)] = 224;
        lookupTable[uint256(53919893334301279589334030174039261347274288845081144962207220498432)] = 225;
        lookupTable[uint256(107839786668602559178668060348078522694548577690162289924414440996864)] = 226;
        lookupTable[uint256(215679573337205118357336120696157045389097155380324579848828881993728)] = 227;
        lookupTable[uint256(431359146674410236714672241392314090778194310760649159697657763987456)] = 228;
        lookupTable[uint256(862718293348820473429344482784628181556388621521298319395315527974912)] = 229;
        lookupTable[uint256(1725436586697640946858688965569256363112777243042596638790631055949824)] = 230;
        lookupTable[uint256(3450873173395281893717377931138512726225554486085193277581262111899648)] = 231;
        lookupTable[uint256(6901746346790563787434755862277025452451108972170386555162524223799296)] = 232;
        lookupTable[uint256(13803492693581127574869511724554050904902217944340773110325048447598592)] = 233;
        lookupTable[uint256(27606985387162255149739023449108101809804435888681546220650096895197184)] = 234;
        lookupTable[uint256(55213970774324510299478046898216203619608871777363092441300193790394368)] = 235;
        lookupTable[uint256(110427941548649020598956093796432407239217743554726184882600387580788736)] = 236;
        lookupTable[uint256(220855883097298041197912187592864814478435487109452369765200775161577472)] = 237;
        lookupTable[uint256(441711766194596082395824375185729628956870974218904739530401550323154944)] = 238;
        lookupTable[uint256(883423532389192164791648750371459257913741948437809479060803100646309888)] = 239;
        lookupTable[uint256(1766847064778384329583297500742918515827483896875618958121606201292619776)] = 240;
        lookupTable[uint256(3533694129556768659166595001485837031654967793751237916243212402585239552)] = 241;
        lookupTable[uint256(7067388259113537318333190002971674063309935587502475832486424805170479104)] = 242;
        lookupTable[uint256(14134776518227074636666380005943348126619871175004951664972849610340958208)] = 243;
        lookupTable[uint256(28269553036454149273332760011886696253239742350009903329945699220681916416)] = 244;
        lookupTable[uint256(56539106072908298546665520023773392506479484700019806659891398441363832832)] = 245;
        lookupTable[uint256(113078212145816597093331040047546785012958969400039613319782796882727665664)] = 246;
        lookupTable[uint256(226156424291633194186662080095093570025917938800079226639565593765455331328)] = 247;
        lookupTable[uint256(452312848583266388373324160190187140051835877600158453279131187530910662656)] = 248;
        lookupTable[uint256(904625697166532776746648320380374280103671755200316906558262375061821325312)] = 249;
        lookupTable[uint256(1809251394333065553493296640760748560207343510400633813116524750123642650624)] = 250;
        lookupTable[uint256(3618502788666131106986593281521497120414687020801267626233049500247285301248)] = 251;
        lookupTable[uint256(7237005577332262213973186563042994240829374041602535252466099000494570602496)] = 252;
        lookupTable[uint256(14474011154664524427946373126085988481658748083205070504932198000989141204992)] = 253;
        lookupTable[uint256(28948022309329048855892746252171976963317496166410141009864396001978282409984)] = 254;
        lookupTable[uint256(57896044618658097711785492504343953926634992332820282019728792003956564819968)] = 255;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}. DON'T CALL IN CONTRACTS THAT AREN'T VIEW FUNCTIONS. 
     * This function is O(N) and can potentially incur high gas cost if called outside of a VIEW function.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        uint256 count = 0;
        uint256 region;
        uint256 mask;
        uint256[] memory bitmap = _bitmap;
        for (uint256 i = getNextIndexIncrement(bitmap[0]); i < bitmap.length << 8; i++) {
            mask = 1 << uint8(i);
            region = i >> 8;
            if (mask & bitmap[region] != 0 && ERC721.ownerOf(i) == owner) {
                if (count == index) {
                    return i;
                }
                count++;
            }
            if (region + 1 < bitmap.length) {
                i += getNextIndexIncrement(combineBitMasks(bitmap[region], bitmap[region + 1], uint16(uint8(i)) + 1));
            } else {
                i += getNextIndexIncrement(bitmap[region] >> (uint16(uint8(i)) + 1));
            }
        }
        revert("ERC721EnumerableS: Unable to find token");
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        uint256 sum = 0;
        uint16[] memory counter = _counter;
        for (uint256 i = 0; i < counter.length; i++) {
           sum += counter[i];
        }
        return sum;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
     function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721EnumerableS.totalSupply(), "ERC721Enumerable: global index out of bounds");
        uint256 count = 0;
        uint256 region = 0;
        uint256 mask;
        uint256[] memory bitmap = _bitmap;
        uint16[] memory counter = _counter;
        for (uint256 i = 0; i < counter.length; i++) {
            if (counter[i] + count < index) {
                count += counter[i];
                region++;
            } else {
                break;
            }
        }
        for (uint256 i = getNextIndexIncrement(bitmap[region]) + (region << 8); i < bitmap.length << 8; i++) {
            mask = 1 << uint8(i);
            region = i >> 8;
            if (mask & bitmap[region] != 0) {
                if (count == index) {
                    return i;
                }
                count++;
            }
            if (region + 1 < bitmap.length) {
                i += getNextIndexIncrement(combineBitMasks(bitmap[region], bitmap[region + 1], uint16(uint8(i)) + 1));
            } else {
                i += getNextIndexIncrement(bitmap[region] >> (uint16(uint8(i)) + 1));
            }
        }
        revert("ERC721EnumerableS: Unable to find token");
     }

    function getNextIndexIncrement(uint256 bitmask) internal view returns(uint16) {
        //Looking at the lowest 4 bits with if statements saves on gas
        if (bitmask & 1 != 0) return 0;
        if (bitmask & 2 != 0) return 1; 
        if (bitmask & 4 != 0) return 2;
        if (bitmask & 8 != 0) return 3;
        return lookupTable[isolateLSB(bitmask)];
    }

    function isolateLSB(uint256 bitmask) internal pure returns(uint256) {
        //Isolates the Least Significant Bit of a bitmask
        unchecked {
            return (bitmask & (0 - bitmask));
        }
    }

    function combineBitMasks(uint256 current, uint256 next, uint16 index) internal pure returns(uint256) {
        // Take the first few bits from the next part of the bitmap and splice it into the current bitmask 
        // This ensure we don't skip over any regions accidentally 
        return  next << (256 - index) | current >> index;
    }


    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } 
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        }
    }


    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        while(tokenId >> 8 >= _bitmap.length) {
            _bitmap.push(0);
            _counter.push(0);
        }
        uint8 pos = uint8(tokenId);
        uint256 index = tokenId >> 8;
        uint256 mask = 1 << pos;
        _bitmap[index] = _bitmap[index] | mask;
        _counter[index]++;
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        uint8 pos = uint8(tokenId);
        uint256 index = tokenId >> 8;
        uint256 mask = 1 << pos;
        mask = mask ^ 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
        _bitmap[index] = _bitmap[index] & mask;
        _counter[index]--;
    }
}