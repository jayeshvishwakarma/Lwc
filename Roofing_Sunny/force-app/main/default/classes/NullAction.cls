public class NullAction {
  @InvocableMethod(label='Null Action' description='Does Nothing.')
  public static void doNothing() {
    System.debug('*** Did Nothing');
  }
}