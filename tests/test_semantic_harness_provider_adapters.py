from __future__ import annotations

import shutil
import sys
import unittest
from pathlib import Path


REPOSITORY = Path(__file__).resolve().parents[1]
CORE_REPOSITORY = REPOSITORY.parent / "psychopatzCore"
CORE_TOOLS = str(CORE_REPOSITORY / "tools")
if CORE_TOOLS not in sys.path:
    sys.path.insert(0, CORE_TOOLS)
if str(CORE_REPOSITORY) not in sys.path:
    sys.path.insert(0, str(CORE_REPOSITORY))
if str(REPOSITORY) not in sys.path:
    sys.path.insert(0, str(REPOSITORY))

from tools.semantic_harness.provider_registry import (  # noqa: E402
    SEMANTIC_EXECUTION_SCHEMA,
    core_registry,
)
from tools.semantic_harness.process import LuaProcess, WorkerLaunchSpec  # noqa: E402
from tools.providers.dt.provider_adapters import (  # noqa: E402
    DT_ABSTRACT_PROVIDER_ID,
    DT_COMMON_PROVIDER_ID,
    DT_HOOMANS_PROVIDER_ID,
    compose_dynamic_trading_profile,
    profile_provider_ids,
    provider_worker_launch_values,
    register_dynamic_trading_profiles,
)


class DynamicTradingProviderAdapterTests(unittest.TestCase):
    def test_abstract_and_physical_selections_feed_core_launch_specs(self) -> None:
        for profile_id, mode in (
            ("dtabstract", "abstract"),
            ("dthoomans", "physical"),
        ):
            selection = compose_dynamic_trading_profile(profile_id)
            spec = WorkerLaunchSpec.from_profile_selection(
                selection,
                lua_bin=Path(sys.executable),
                worker_script=CORE_REPOSITORY
                / "tools/semantic_harness/lua/worker.lua",
                core_repository=CORE_REPOSITORY,
            )
            self.assertEqual(spec.profile, profile_id)
            self.assertEqual(spec.materialization_mode, mode)
            self.assertEqual(
                spec.neutral_environment(),
                selection.launch_environment(),
            )

    def test_profile_selection_emits_core_worker_launch_metadata(self) -> None:
        selection = compose_dynamic_trading_profile(
            "dtabstract",
            available_provider_ids=(
                "PsychopatzCore",
                DT_COMMON_PROVIDER_ID,
                DT_ABSTRACT_PROVIDER_ID,
            ),
        )

        self.assertEqual(
            selection.launch_environment(),
            {
                "SEMANTIC_HARNESS_PROFILE": "dtabstract",
                "SEMANTIC_HARNESS_PROVIDER_IDS": (
                    "PsychopatzCore,DTCommon,DTAbstract"
                ),
                "SEMANTIC_HARNESS_MATERIALIZATION_MODE": "abstract",
            },
        )

    def test_abstract_and_physical_profiles_share_core_execution_contract(self) -> None:
        registry = register_dynamic_trading_profiles(core_registry())

        abstract = registry.resolve(
            "dtabstract",
            available_provider_ids=(
                "PsychopatzCore",
                DT_COMMON_PROVIDER_ID,
                DT_ABSTRACT_PROVIDER_ID,
            ),
        )
        physical = registry.resolve(
            "dthoomans",
            available_provider_ids=(
                "PsychopatzCore",
                DT_COMMON_PROVIDER_ID,
                DT_HOOMANS_PROVIDER_ID,
            ),
        )

        self.assertEqual(abstract.profile.materialization_mode, "abstract")
        self.assertEqual(physical.profile.materialization_mode, "physical")
        self.assertEqual(
            abstract.provider_ids,
            profile_provider_ids("dtabstract"),
        )
        self.assertEqual(
            physical.provider_ids,
            profile_provider_ids("dthoomans"),
        )

        common = registry.provider(DT_COMMON_PROVIDER_ID)
        abstract_provider = registry.provider(DT_ABSTRACT_PROVIDER_ID)
        physical_provider = registry.provider(DT_HOOMANS_PROVIDER_ID)
        self.assertIsNotNone(common)
        self.assertEqual(common.execution_schema, SEMANTIC_EXECUTION_SCHEMA)
        self.assertEqual(
            common.execution_callbacks,
            abstract_provider.execution_callbacks,
        )
        self.assertEqual(
            abstract_provider.execution_callbacks,
            physical_provider.execution_callbacks,
        )

    def test_abstract_profile_does_not_require_physical_adopter(self) -> None:
        registry = register_dynamic_trading_profiles(
            core_registry(), include_hoomans=False
        )
        resolved = registry.resolve(
            "dtabstract",
            available_provider_ids=(
                "PsychopatzCore",
                DT_COMMON_PROVIDER_ID,
                DT_ABSTRACT_PROVIDER_ID,
            ),
        )
        self.assertNotIn(DT_HOOMANS_PROVIDER_ID, resolved.provider_ids)

    def test_dt_profiles_load_through_the_core_worker(self) -> None:
        lua = shutil.which("lua")
        if lua is None:
            self.skipTest("lua executable is required for the worker gate")
        for profile_id, mode, provider_id in (
            ("dtabstract", "abstract", DT_ABSTRACT_PROVIDER_ID),
            ("dthoomans", "physical", DT_HOOMANS_PROVIDER_ID),
        ):
            selection = compose_dynamic_trading_profile(profile_id)
            spec = WorkerLaunchSpec.from_profile_selection(
                selection,
                **provider_worker_launch_values(profile_id, REPOSITORY),
                lua_bin=Path(lua),
                worker_script=CORE_REPOSITORY
                / "tools/semantic_harness/lua/worker.lua",
                core_repository=CORE_REPOSITORY,
                working_directory=CORE_REPOSITORY,
            )
            runtime = LuaProcess(spec)
            try:
                hello = runtime.start()
                self.assertEqual(hello["profile"], profile_id)
                self.assertEqual(hello["materializationMode"], mode)
                self.assertEqual(hello["executionProviderID"], provider_id)
                self.assertEqual(
                    hello["providerAdapters"][0]["providerID"],
                    provider_id,
                )
                response = runtime.request(
                    "SEMANTIC_PROVIDER",
                    {"operation": "submitText", "text": "hello"},
                )
                self.assertEqual(response["providerID"], provider_id)
                self.assertEqual(response["result"]["text"], "hello")
            finally:
                runtime.close()


if __name__ == "__main__":
    unittest.main()
