import { ThemeProvider, UnifiedTheme, Button } from "@revolut/ui-kit";
import { App } from "./App";

export const AppProvider = () => {
  return (
    <ThemeProvider theme={UnifiedTheme}>
      <App />
    </ThemeProvider>
  );
};
