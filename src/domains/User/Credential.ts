import { object, Result, notEmpty } from "src/toolkit/Result";

export type Credential = {
  username: string;
  password: string;
};

const CRED_KEY = "CRED";

export const getCredentials = (): Credential | null => {
  return JSON.parse(localStorage.getItem(CRED_KEY) || "null");
};

export const deleteCredential = (credential: Credential): void => {
  localStorage.removeItem(CRED_KEY);
};

export const saveCredentials = (credential: Credential): void => {
  localStorage.setItem(CRED_KEY, JSON.stringify(credential));
};

export type CredentialValidationError = {
  username?: { type: "value_is_empty" };
  password?: { type: "value_is_empty" };
};
export const validateCredential = (
  form: Partial<Credential>
): Result<CredentialValidationError, Credential> => {
  return object({
    username: notEmpty(form.password),
    password: notEmpty(form.password),
  });
};
