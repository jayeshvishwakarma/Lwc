/**
 * This class is specific to create the JSON Data on account or case record
 */

public without sharing class CreateStakeHolderJson {

    public static String createJson(String ObjectType) {
        StakeholderHierarchy stakeholderHierarchy = new StakeholderHierarchy();
        if (ObjectType == ConstantsUtility.ACCOUNT_OBJ) {
            stakeholderHierarchy.sales = new List<StakeholderHierarchy.Sales>();
            stakeholderHierarchy.serviceNexa = new List<StakeholderHierarchy.Sales>();
            stakeholderHierarchy.serviceArena = new List<StakeholderHierarchy.Sales>();
            stakeholderHierarchy.accessories = new List<StakeholderHierarchy.Sales>();
            stakeholderHierarchy.trueValue = new List<StakeholderHierarchy.Sales>();
            stakeholderHierarchy.msds = new List<StakeholderHierarchy.Sales>();
            stakeholderHierarchy.msgp = new List<StakeholderHierarchy.Sales>();
            stakeholderHierarchy.msilQuery = new List<StakeholderHierarchy.Sales>();
            stakeholderHierarchy.loyaltyProgram = new List<StakeholderHierarchy.Sales>();
            stakeholderHierarchy.finance = new List<StakeholderHierarchy.Sales>();
            stakeholderHierarchy.sales = getStakeHolderList();
            stakeholderHierarchy.serviceNexa = getStakeHolderList();
            stakeholderHierarchy.serviceArena = getStakeHolderList();
            stakeholderHierarchy.accessories = getStakeHolderList();
            stakeholderHierarchy.trueValue = getStakeHolderList();
            stakeholderHierarchy.msds = getStakeHolderList();
            stakeholderHierarchy.msgp = getStakeHolderList();
            stakeholderHierarchy.msilQuery = getStakeHolderList();
            stakeholderHierarchy.loyaltyProgram = getStakeHolderList();
            stakeholderHierarchy.finance = getStakeHolderList();
            stakeholderHierarchy.suzukiConnect = getStakeHolderList();
        }
        return JSON.serialize(stakeholderHierarchy);


    }
    private static List<StakeholderHierarchy.Sales> getStakeHolderList() {
        List<StakeholderHierarchy.Sales> holderList = new List<StakeholderHierarchy.Sales>();
        holderList.add(getStakeholderHierarchy('L1A'));
        holderList.add(getStakeholderHierarchy('L1B'));
        holderList.add(getStakeholderHierarchy('L2A'));
        holderList.add(getStakeholderHierarchy('L2B'));
        holderList.add(getStakeholderHierarchy('L3A'));
        holderList.add(getStakeholderHierarchy('L4'));
        holderList.add(getStakeholderHierarchy('L5'));
        holderList.add(getStakeholderHierarchy('L6A'));
        holderList.add(getStakeholderHierarchy('L6B'));
        holderList.add(getStakeholderHierarchy('L7'));
        holderList.add(getStakeholderHierarchy('L8A'));
        holderList.add(getStakeholderHierarchy('L8B'));
        holderList.add(getStakeholderHierarchy('L8C'));
        holderList.add(getStakeholderHierarchy('L8D'));
        holderList.add(getStakeholderHierarchy('L8E'));
        holderList.add(getStakeholderHierarchy('L9'));
        holderList.add(getStakeholderHierarchy('L10'));
        return holderList;
    }
    private static StakeholderHierarchy.Sales getStakeholderHierarchy(String refName) {
        StakeholderHierarchy.Sales holder = new StakeholderHierarchy.Sales();
        holder.recordId = UserInfo.getUserId();
        holder.stakeHolder = refName;
        holder.refName = UserInfo.getName();
        holder.email = 'test@email.com';
        holder.phone = '9876543210';
        return holder;
    }
}