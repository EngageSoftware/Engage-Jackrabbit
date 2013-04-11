﻿// <copyright file="CanBeNullAttribute.cs" company="JetBrains s.r.o.">
// Copyright 2007-2012 JetBrains s.r.o.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// </copyright>

namespace JetBrains.Annotations
{
    using System;

    /// <summary>Indicates that the value of the marked element could be <c>null</c> sometimes,
    /// so the check for <c>null</c> is necessary before its usage.</summary>
    /// <example>
    ///   <code>
    /// [CanBeNull]
    /// public object Test()
    /// {
    /// return null;
    /// }
    /// public void UseTest()
    /// {
    /// var p = Test();
    /// var s = p.ToString(); // Warning: Possible 'System.NullReferenceException'
    /// }
    ///   </code>
    /// </example>
    [AttributeUsage(AttributeTargets.Method | AttributeTargets.Parameter | AttributeTargets.Property | AttributeTargets.Delegate | AttributeTargets.Field, AllowMultiple = false, Inherited = true)]
    public sealed class CanBeNullAttribute : Attribute
    {
    }
}