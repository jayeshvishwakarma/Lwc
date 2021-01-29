@istest
public class twod_HexUtil_Test {
    public static testmethod void TestOne(){
        twod_HexUtil objHex = new twod_HexUtil();
        twod_HexUtil.CRC32Table(blob.valueOf('rwerrwfs'));
        twod_HexUtil.CRC32Table('sdhfkshf');
        twod_HexUtil.hexToIntLE('hhasdkashd');
        twod_HexUtil.intToHexLE(4, 5);
    }
}