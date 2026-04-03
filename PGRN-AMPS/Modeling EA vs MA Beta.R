# 1. BETA comparisons between EA and MA PRS
# EA model
ea_summary <- summary(model2)
ea_beta <- ea_summary$coefficients["EA_PRS_z", "Estimate"]
ea_se <- ea_summary$coefficients["EA_PRS_z", "Std. Error"]

ea_lower <- ea_beta - 1.96 * ea_se
ea_upper <- ea_beta + 1.96 * ea_se

# MA model
ma_summary <- summary(model2_MA)
ma_beta <- ma_summary$coefficients["MA_PRS_z", "Estimate"]
ma_se <- ma_summary$coefficients["MA_PRS_z", "Std. Error"]

ma_lower <- ma_beta - 1.96 * ma_se
ma_upper <- ma_beta + 1.96 * ma_se

comparison_df <- data.frame(
  Ancestry = c("European Ancestry (EA)", "Multi-Ancestry (MA)"),
  Beta = c(ea_beta, ma_beta),
  Lower = c(ea_lower, ma_lower),
  Upper = c(ea_upper, ma_upper)
)

EA_color <- "steelblue"
MA_color <- "#B22222"

ggplot(comparison_df, aes(x = Beta, y = Ancestry, color = Ancestry)) +
  geom_point(size = 4) +
  geom_errorbarh(aes(xmin = Lower, xmax = Upper), height = 0.2, linewidth = 1) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
  scale_color_manual(values = c(EA_color, MA_color)) +
  labs(
    title = "Comparison of Adjusted PRS Effects on Age of Onset",
    x = "Standardized Beta (PRS → Age of Onset)",
    y = ""
  ) +
  theme_classic(base_size = 14) +
  theme(
    legend.position = "none",
    plot.title = element_text(hjust = 0.5, face = "bold")
  )