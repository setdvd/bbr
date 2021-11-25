import { Persistance, LOCAL_STORAGE_KEY } from "../Persistance";

export const savePersistance = (persistance: Persistance): void => {
  localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(persistance));
};
