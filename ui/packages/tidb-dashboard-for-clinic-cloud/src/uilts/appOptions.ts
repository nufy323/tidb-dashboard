import { ISlowQueryConfig, ITopSQLConfig } from '@pingcap/tidb-dashboard-lib'
import { ClientOptions } from '~/client'

export type AppOptions = {
  lang: string
  hideNav: boolean

  skipNgmCheck: boolean
  skipLoadAppInfo: boolean
  skipReloadWhoAmI: boolean
}

export const defAppOptions: AppOptions = {
  lang: 'en',
  hideNav: false,

  skipNgmCheck: false,
  skipLoadAppInfo: false,
  skipReloadWhoAmI: false
}

const optionsKey = 'dashboard_app_options'

export function saveAppOptions(options: AppOptions) {
  localStorage.setItem(optionsKey, JSON.stringify(options))
}

export function loadAppOptions(): AppOptions {
  const s = localStorage.getItem(optionsKey)
  if (s === null) {
    return defAppOptions
  }
  const opt = JSON.parse(s)
  if (!!opt && opt.constructor === Object) {
    return opt
  }
  return defAppOptions
}

////////////////////////////////////

export type AppsConfig = {
  slowQuery?: Partial<ISlowQueryConfig>
  topSQL?: Partial<ITopSQLConfig>
}

export type StartOptions = {
  clientOptions: ClientOptions
  appOptions?: AppOptions
  appsConfig?: AppsConfig
}

let _startOptions: StartOptions

export function setStartOptions(opt: StartOptions) {
  _startOptions = opt
}

export function getStartOptions(): StartOptions {
  return _startOptions
}
