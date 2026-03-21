public class SetNetworkModePoll {
    public static void main(String[] args) {
        if (args.length < 2) {
            System.err.println("Usage: SetNetworkModePoll <subId> <mode>");
            System.exit(1);
        }
        int subId = Integer.parseInt(args[0]);
        long mode = Long.parseLong(args[1]);
        try {
            Class<?> smCl = Class.forName("android.os.ServiceManager");
            java.lang.reflect.Method mGetService = smCl.getMethod("getService", String.class);
            Object binder = mGetService.invoke(null, "phone");
            Class<?> stubCl = Class.forName("com.android.internal.telephony.ITelephony$Stub");
            java.lang.reflect.Method mAsInterface = stubCl.getMethod("asInterface", Class.forName("android.os.IBinder"));
            Object itelephony = mAsInterface.invoke(null, binder);
            java.lang.reflect.Method mSet = null;
            for (java.lang.reflect.Method m : itelephony.getClass().getMethods()) {
                if (m.getName().equals("setAllowedNetworkTypesForReason")) {
                    mSet = m;
                    break;
                }
            }
            if (mSet != null) {
                mSet.invoke(itelephony, subId, 0, mode);
            } else {
                System.err.println("Method not found");
                System.exit(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
    }
}
