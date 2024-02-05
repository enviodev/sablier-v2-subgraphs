import {
  MerkleLockupFactoryV21Contract_CreateMerkleStreamerLL_handlerAsync as HandlerLinearAsync_V21,
  MerkleLockupFactoryV21Contract_CreateMerkleStreamerLL_loader as LoaderLinear_V21,
} from "../../generated/src/Handlers.gen";

import type { CreateLinearLoader, CreateLinearHandler, Action } from "../types";

import {
  createAction,
  createLinearCampaign,
  generateAssetId,
  generateFactoryIdFromEvent,
  getOrCreateAsset_async,
  initialize_async,
} from "../helpers";
import { ActionCategory } from "../constants";

function loader(input: CreateLinearLoader) {
  const { context, event } = input;

  const assetId = generateAssetId(event, event.params.asset);
  const factoryId = generateFactoryIdFromEvent(event);
  const watcherId = event.chainId.toString();

  context.Asset.load(assetId);
  context.Factory.load(factoryId);
  context.Watcher.load(watcherId);

  // TODO: uncomment when next version is stable. In version 0.0.29 of envio - dynamic contracts sometimes mis-behave (especially when there are multiple in the same batch).
  // context.contractRegistration.addMerkleLLV21(event.params.merkleStreamer);
}

async function handlerLinear(input: CreateLinearHandler) {
  const { context, event } = input;

  /** ------- Initialize -------- */

  let { watcher, factory, factories } = await initialize_async(
    event,
    context.Watcher.get,
    context.Factory.get,
  );

  /** ------- Fetch -------- */

  let asset = await getOrCreateAsset_async(
    event,
    event.params.asset,
    context.Asset.get,
  );

  /** ------- Process -------- */

  let { campaign, ...post_create } = await createLinearCampaign(event, {
    asset,
    factory,
    watcher,
  });

  watcher = post_create.watcher;

  const post_action = createAction(event, watcher);

  watcher = post_action.watcher;

  const action: Action = {
    ...post_action.entity,
    category: ActionCategory.Create,
    campaign: campaign.id,

    from: event.params.admin.toLowerCase(), // TODO missing event.transaction.from, remove when available
  };

  /** ------- Update -------- */

  await context.Asset.set(asset);
  if (factories.length) {
    for (let i = 0; i < factories.length; i++) {
      if (factories[i].id === factory.id) {
        await context.Factory.set(factory);
      }
      await context.Factory.set(factories[i]);
    }
  }

  await context.Action.set(action);
  await context.Campaign.set(campaign);
  await context.Watcher.set(watcher);
}

LoaderLinear_V21(loader);
HandlerLinearAsync_V21(handlerLinear);
