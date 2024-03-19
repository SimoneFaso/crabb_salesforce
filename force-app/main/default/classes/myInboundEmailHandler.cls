/**
 * Created by MatteoSala on 04/11/2021.
 */

global class myInboundEmailHandler implements Messaging.InboundEmailHandler
{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        return result;
    }
}