import { BaseLocator } from "../../BaseLocator";

export class LoginLocator extends BaseLocator {
    constructor() {
        super();
    }

    form = {
        txt_Username: '#username',
        txt_Password: '#password', 
        btn_Login: 'button:has-text("Login")',
        msg_Error: '.alert-danger, .error-message',
        msg_Success: '.alert-success, .success-message'
    };
}