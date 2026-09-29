return {
    dynamicTradingRuntime = "42.20",
    projectHoomansRuntime = "42.20",
    psychopatzCoreRuntime = "42.20",
    projectHoomansRepository = os.getenv("PZ_TEST_HOOMANS_REPOSITORY")
        or "../ProjectHoomans",
    psychopatzCoreRepository = os.getenv("PZ_TEST_CORE_REPOSITORY")
        or "../psychopatzCore",
}
