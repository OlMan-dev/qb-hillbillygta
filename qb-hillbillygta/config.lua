Config = {}

Config.HillbillyModel = 's_m_y_xmech_02_mp' 
Config.HillbillyLocation = vector4(2003.83, 3791.41, 31.18, 265.07) 

Config.DeliveryLocation = vector4(2004.54, 3797.26, 32.18, 127.3)

Config.CarLocations = {
    vector4(1300.96, 3633.15, 33.04, 313.64),
	vector4(900.13, 3653.09, 32.76, 91.5),
	vector4(917.63, 3563.16, 33.8, 282.3),
	vector4(472.32, 3567.81, 33.24, 353.8),
	vector4(398.67, 3573.22, 33.29, 290.31),
	vector4(315.81, 3448.07, 36.34, 45.33),
	vector4(321.8, 3413.27, 36.69, 250.36),
	vector4(314.56, 2823.66, 43.44, 38.01),
	vector4(214.98, 2803.97, 45.66, 101.39),
	vector4(258.18, 2577.66, 45.17, 94.67),
	vector4(331.08, 2614.04, 44.5, 20.21),
	vector4(572.86, 2680.69, 41.87, 27.17),
	vector4(1020.3, 2663.63, 39.57, 266.64),
	vector4(1138.4, 2628.18, 38.0, 272.11),
	vector4(1724.98, 3035.14, 61.45, 20.79),
	vector4(2057.34, 3178.37, 45.17, 64.54),
	vector4(2050.48, 3456.56, 43.77, 79.8),
	vector4(2095.59, 3568.84, 41.77, 316.3),
	vector4(2483.9, 3821.59, 40.23, 105.8),
	vector4(2459.6, 4051.54, 37.79, 333.27),
	vector4(2491.8, 4122.08, 38.18, 152.97),
	vector4(2680.68, 4317.36, 45.85, 317.44),
	vector4(2346.35, 3085.73, 48.08, 37.45),
	vector4(1218.32, 2392.37, 65.95, 165.44),
	vector4(1222.51, 1874.13, 78.92, 35.66),
	vector4(1530.67, 1713.04, 109.93, 28.83),
	vector4(2659.19, 3261.74, 55.24, 143.04),
	vector4(2711.43, 3443.53, 55.73, 152.86),
	vector4(2904.4, 4396.43, 50.27, 201.57),
	vector4(2515.49, 4220.74, 39.91, 234.77),
	vector4(1789.57, 4585.01, 37.38, 183.4),
	vector4(1682.91, 4832.33, 42.04, 91.99),
	vector4(1708.35, 4943.71, 42.17, 54.09),
	vector4(1973.42, 5180.72, 47.86, 133.28),
	vector4(2927.01, 4626.4, 48.55, 322.11),
	vector4(2865.24, 4477.16, 48.35, 247.98),
	vector4(2786.23, 3463.15, 55.4, 59.54),
	vector4(2659.82, 1671.3, 24.49, 262.91),
	vector4(555.88, 2734.1, 42.06, 179.09),
	vector4(2573.66, 4657.06, 34.08, 38.51)
	
}

Config.CarModels = {
    'tornado6', 'ratloader', 'emperor2', 'tornado3', 'tornado4', 'rebel', 'bfinjection'
}

-- Hotwire Minigame Settings
Config.minHotwireTime = 15000 
Config.maxHotwireTime = 30000

-- Min Police Settings
Config.MinPolice = 0 

-- Payment after delivering the car
Config.RewardMin = 500
Config.RewardMax = 1500

Config.Lang = {
	['cops'] = "Come back later",
    ['go_steal_car'] = "Get the car with the plate number %s. It's located near %s",
    ['reward_message'] = "The Billy Joe wired you $%d for the car."
}

